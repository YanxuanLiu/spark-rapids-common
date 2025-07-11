# Check shell syntax
FILES="shell-test.sh"
# Initialize variables
error_log="shell_errors.log"
error_count=0
failed_files=()

# Clean up any previous error log
rm -f "$error_log"
for FILE in "${FILES[@]}"; do
    
    # Create a temporary file for this file's errors
    tmp_error=$(mktemp)
    
    # Check if file exists
    # Run bash -n syntax check
    bash -n "$FILE" > >(tee -a "$tmp_error") 2>&1 || {
        echo "❌ bash -n failed for $FILE" | tee -a "$tmp_error"
        ((error_count++))
    }
        
    # Run shellcheck
    shellcheck --color=always "$FILE" > >(tee -a "$tmp_error") 2>&1 || {
        echo "❌ shellcheck failed for $FILE" | tee -a "$tmp_error"
        ((error_count++))
    }
    
    # If errors were found, add to main log
    if [ -s "$tmp_error" ]; then
        failed_files+=("$FILE")
        echo -e "\n=== Errors in $FILE ===" >> "$error_log"
        cat "$tmp_error" >> "$error_log"
        echo -e "\n" >> "$error_log"
    fi
    
    rm -f "$tmp_error"
done

# Final report
if [ -s "$error_log" ]; then
    echo -e "\n❌ Found $error_count errors in ${#failed_files[@]} files:"
    printf ' - %s\n' "${failed_files[@]}"
    
    echo "::group::Detailed Error Report"
    cat "$error_log"
    echo "::endgroup::"
    
    # Create GitHub annotations for each error
    while IFS= read -r line; do
        if [[ "$line" == *:*:*:* ]]; then
            # Extract filename, line number, and message
            file_path=$(echo "$line" | cut -d: -f1)
            line_num=$(echo "$line" | cut -d: -f2)
            message=$(echo "$line" | cut -d: -f4- | sed 's/^ *//')
            
            echo "::error file=$file_path,line=$line_num::$message"
        fi
    done < "$error_log"
    
    echo "::error::Found $error_count shell script errors"
    exit 1
else
    echo "✅ No shell script errors found"
fi