#!/bin/bash

set -e

# Global variables
DRY_RUN=false
FORCE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dry-run, --dryrun    Show what would be done without actually triggering workflows"
    echo "  --force                Force trigger workflows even if they are currently running"
    echo "  -h, --help             Show this help message"
    echo ""
    echo "Description:"
    echo "  Checks the status of all GitHub workflows in the repository and restarts"
    echo "  any that have failed. Works from any directory within the git repository."
    echo ""
    echo "  By default, workflows that are currently running will be skipped unless"
    echo "  --force is specified. Disabled workflows are always skipped."
    echo ""
}

# Function to parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run|--dryrun)
                DRY_RUN=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                print_status "$RED" "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to find the git repository root
find_git_root() {
    local current_dir=$(pwd)
    while [[ "$current_dir" != "/" ]]; do
        if [[ -d "$current_dir/.git" ]]; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    echo ""
    return 1
}

# Function to check if gh CLI is installed and authenticated
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        print_status "$RED" "Error: GitHub CLI (gh) is not installed."
        print_status "$YELLOW" "Please install it from: https://cli.github.com/"
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_status "$RED" "Error: GitHub CLI is not authenticated."
        print_status "$YELLOW" "Please run: gh auth login"
        exit 1
    fi
}

# Function to get all workflow files
get_workflow_files() {
    local repo_root=$1
    local workflow_dir="$repo_root/.github/workflows"
    
    if [[ ! -d "$workflow_dir" ]]; then
        print_status "$RED" "Error: No .github/workflows directory found in $repo_root"
        exit 1
    fi
    
    find "$workflow_dir" -name "*.yml" -o -name "*.yaml" | sort
}

# Function to extract workflow name from file
get_workflow_name_from_file() {
    local workflow_file=$1
    # Try to extract name from the YAML file
    local name=$(grep -E "^name:" "$workflow_file" | head -1 | sed 's/name:[[:space:]]*//' | sed 's/^["\x27]//' | sed 's/["\x27]$//')
    
    if [[ -z "$name" ]]; then
        # If no name found, use filename without extension
        name=$(basename "$workflow_file" | sed 's/\.\(yml\|yaml\)$//')
    fi
    
    echo "$name"
}

# Function to check if a workflow is disabled
is_workflow_disabled() {
    local workflow_name=$1
    local workflow_info
    
    # Get workflow info including state
    workflow_info=$(gh workflow view "$workflow_name" --json=state 2>/dev/null || echo "")
    
    if [[ -z "$workflow_info" || "$workflow_info" == "{}" ]]; then
        echo "active"  # Default to active if we can't determine state
        return
    fi
    
    local state=$(echo "$workflow_info" | jq -r '.state // "active"')
    echo "$state"
}

# Function to get the latest run status for a workflow
get_latest_run_status() {
    local workflow_name=$1
    local run_info
    
    # Get the latest run for this workflow
    run_info=$(gh run list --workflow="$workflow_name" --limit=1 --json=status,conclusion,databaseId 2>/dev/null || echo "")
    
    if [[ -z "$run_info" || "$run_info" == "[]" ]]; then
        echo "no_runs"
        return
    fi
    
    local status=$(echo "$run_info" | jq -r '.[0].status // "unknown"')
    local conclusion=$(echo "$run_info" | jq -r '.[0].conclusion // "null"')
    local run_id=$(echo "$run_info" | jq -r '.[0].databaseId // "unknown"')
    
    echo "${status}:${conclusion}:${run_id}"
}

# Function to trigger a workflow
trigger_workflow() {
    local workflow_name=$1
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "$CYAN" "  [DRY RUN] Would trigger workflow: $workflow_name"
        return 0
    else
        print_status "$BLUE" "  Triggering workflow: $workflow_name"
        
        if gh workflow run "$workflow_name" 2>/dev/null; then
            print_status "$GREEN" "  ✓ Successfully triggered workflow: $workflow_name"
            return 0
        else
            print_status "$RED" "  ✗ Failed to trigger workflow: $workflow_name"
            print_status "$YELLOW" "    This might be because the workflow doesn't have workflow_dispatch trigger"
            return 1
        fi
    fi
}

# Main function
main() {
    # Parse command line arguments first
    parse_arguments "$@"
    
    if [[ "$DRY_RUN" == true ]]; then
        print_status "$CYAN" "GitHub Workflow Status Checker and Restarter (DRY RUN MODE)"
        print_status "$CYAN" "============================================================="
        print_status "$YELLOW" "Note: Running in dry-run mode - no workflows will actually be triggered"
        echo
    else
        print_status "$BLUE" "GitHub Workflow Status Checker and Restarter"
        print_status "$BLUE" "============================================="
    fi
    
    # Check prerequisites
    check_gh_cli
    
    # Find git repository root
    local repo_root
    repo_root=$(find_git_root)
    if [[ -z "$repo_root" ]]; then
        print_status "$RED" "Error: Not inside a Git repository"
        exit 1
    fi
    
    print_status "$GREEN" "Repository root: $repo_root"
    
    # Get all workflow files
    local workflow_files
    workflow_files=$(get_workflow_files "$repo_root")
    
    if [[ -z "$workflow_files" ]]; then
        print_status "$YELLOW" "No workflow files found in .github/workflows/"
        exit 0
    fi
    
    local total_workflows=0
    local failed_workflows=0
    local triggered_workflows=0
    local no_runs_workflows=0
    local disabled_workflows=0
    local running_skipped=0
    
    print_status "$BLUE" "\nChecking workflow statuses..."
    print_status "$BLUE" "=============================\n"
    
    # Process each workflow file
    while IFS= read -r workflow_file; do
        if [[ -z "$workflow_file" ]]; then
            continue
        fi
        
        total_workflows=$((total_workflows + 1))
        
        local workflow_name
        workflow_name=$(get_workflow_name_from_file "$workflow_file")
        
        print_status "$BLUE" "Checking: $workflow_name"
        
        # Check if workflow is disabled
        local workflow_state
        workflow_state=$(is_workflow_disabled "$workflow_name")
        
        if [[ "$workflow_state" == "disabled_manually" ]]; then
            print_status "$YELLOW" "  ⚠ Workflow is manually disabled - skipping"
            disabled_workflows=$((disabled_workflows + 1))
            echo
            continue
        fi
        
        # Get latest run status
        local run_status
        run_status=$(get_latest_run_status "$workflow_name")
        
        if [[ "$run_status" == "no_runs" ]]; then
            print_status "$YELLOW" "  ⚠ No previous runs found"
            no_runs_workflows=$((no_runs_workflows + 1))
        else
            IFS=':' read -r status conclusion run_id <<< "$run_status"
            
            case "$conclusion" in
                "success")
                    print_status "$GREEN" "  ✓ Last run: SUCCESS (ID: $run_id)"
                    ;;
                "failure"|"cancelled"|"timed_out")
                    print_status "$RED" "  ✗ Last run: $conclusion (ID: $run_id)"
                    failed_workflows=$((failed_workflows + 1))
                    
                    # Try to trigger the workflow
                    if trigger_workflow "$workflow_name"; then
                        if [[ "$DRY_RUN" == true ]]; then
                            triggered_workflows=$((triggered_workflows + 1))
                        else
                            triggered_workflows=$((triggered_workflows + 1))
                        fi
                    fi
                    ;;
                ""|"null")
                    if [[ "$status" == "in_progress" || "$status" == "queued" || "$status" == "pending" ]]; then
                        print_status "$YELLOW" "  ⏳ Currently running: $status (ID: $run_id)"
                        if [[ "$FORCE" == true ]]; then
                            print_status "$YELLOW" "  ⚡ --force specified, will trigger anyway"
                            # Try to trigger the workflow
                            if trigger_workflow "$workflow_name"; then
                                if [[ "$DRY_RUN" == true ]]; then
                                    triggered_workflows=$((triggered_workflows + 1))
                                else
                                    triggered_workflows=$((triggered_workflows + 1))
                                fi
                            fi
                        else
                            print_status "$YELLOW" "  ⏸ Skipping (use --force to trigger running workflows)"
                            running_skipped=$((running_skipped + 1))
                        fi
                    else
                        print_status "$YELLOW" "  ⚠ Unknown status: $status (conclusion: $conclusion, ID: $run_id)"
                    fi
                    ;;
                *)
                    print_status "$YELLOW" "  ⚠ Unknown conclusion: $conclusion (status: $status, ID: $run_id)"
                    ;;
            esac
        fi
        
        echo
    done <<< "$workflow_files"
    
    # Summary
    print_status "$BLUE" "Summary:"
    print_status "$BLUE" "========"
    print_status "$BLUE" "Total workflows checked: $total_workflows"
    print_status "$RED" "Failed workflows found: $failed_workflows"
    if [[ "$DRY_RUN" == true ]]; then
        print_status "$CYAN" "Workflows that would be triggered: $triggered_workflows"
    else
        print_status "$GREEN" "Workflows triggered: $triggered_workflows"
    fi
    print_status "$YELLOW" "Workflows with no runs: $no_runs_workflows"
    print_status "$YELLOW" "Disabled workflows skipped: $disabled_workflows"
    print_status "$YELLOW" "Running workflows skipped: $running_skipped"
    
    if [[ $triggered_workflows -gt 0 ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            print_status "$CYAN" "\n[DRY RUN] Would trigger $triggered_workflows failed workflow(s)"
            print_status "$YELLOW" "Run without --dry-run to actually trigger the workflows"
        else
            print_status "$GREEN" "\n✓ Successfully triggered $triggered_workflows failed workflow(s)"
        fi
    elif [[ $failed_workflows -gt 0 ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            print_status "$YELLOW" "\n⚠ Found $failed_workflows failed workflow(s) but none could be triggered"
        else
            print_status "$YELLOW" "\n⚠ Found $failed_workflows failed workflow(s) but none could be triggered"
        fi
        print_status "$YELLOW" "  (Workflows need 'workflow_dispatch' trigger to be manually triggered)"
    else
        print_status "$GREEN" "\n✓ All workflows are in good state!"
    fi
    
    # Additional guidance
    if [[ $running_skipped -gt 0 && "$FORCE" == false ]]; then
        print_status "$YELLOW" "\nNote: $running_skipped running workflow(s) were skipped"
        print_status "$YELLOW" "Use --force to trigger workflows even when they are running"
    fi
    
    if [[ $disabled_workflows -gt 0 ]]; then
        print_status "$YELLOW" "\nNote: $disabled_workflows manually disabled workflow(s) were skipped"
        print_status "$YELLOW" "Enable them in GitHub's Actions tab to include them in checks"
    fi
}

# Run main function
main "$@"
