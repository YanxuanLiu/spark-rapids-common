#!/bin/bash
# shellcheck disable=SC2317  # Temporarily disable checks to demonstrate errors

# =====================
# Basic Syntax Errors (detectable by both bash -n and shellcheck)
# =====================



# 1. Unclosed control structure
if [ -f "test_file.txt" ]; then
  echo "File exists"
# Error: Missing 'fi'

# 2. Incomplete pipe command
cat "some_file.txt" |   # Error: Nothing after pipe

# 3. Unclosed function
function test_function {
  echo "Inside function"
# Error: Missing '}'

# =====================
# Semantic Errors (primarily detected by shellcheck)
# =====================

# 4. Unquoted variable with spaces
filename="file with spaces.txt"
rm $filename  # Error: Should be rm "$filename"

# 5. Misuse of exit status
grep "pattern" "some_file.txt"
if [ $? = 0 ]; then  # Error: Should use if grep -q "pattern" file.txt
  echo "Pattern found"
fi

# 6. Uninitialized variable
echo "Value: $undefined_var"  # Error: Variable never defined

# 7. Arithmetic expression error
count=5+3  # Error: Should be count=$((5+3))

# 8. Test expression error
var="value"
if [ "$var" = value ]; then  # Error: value should be quoted
  echo "Equal"
fi

# =====================
# Security/Best Practice Issues (shellcheck only)
# =====================

# 9. Command injection risk
user_input="; echo 'malicious command'"
ls $user_input  # Error: Should use ls -- "$user_input"

# 10. Inefficient loop
for file in $(ls *.txt); do  # Error: Should use for file in *.txt
  echo "$file"
done

# 11. Constant conditional
if [[ 1 -eq 1 ]]; then  # Error: Always true
  echo "Always true"
fi

# 12. Unclosed file descriptor
exec 3< "input.txt"
# Error: Missing exec 3>&-

# =====================
# Portability Issues (shellcheck only)
# =====================

# 13. Bashism in sh script
(
  #!/bin/sh
  echo {1..10}  # Error: {} expansion invalid in POSIX sh
)

# 14. Incompatible test syntax
(
  #!/bin/sh
  if [[ $var == "test" ]]; then  # Error: [[ ]] is bash-specific
    echo "Match"
  fi
)

# =====================
# Compound Error Section
# =====================

# 15. Multiple compound errors
echo "Starting complex error section"

# Unmatched quotes


# Uninitialized variable + unquoted
if [ $debug_mode = "true" ]; then
  echo "Debug mode"
fi

# Broken pipe
cat /var/log/syslog | 

# Security risk
find . -name $user_input

# Unclosed loop
for item in {1..5}; do
  echo "Processing $item"

echo "Unclosed quote"

# =====================
# Cleanup (no actual errors)
# =====================
echo "All errors are intentional test cases"
exit 0
