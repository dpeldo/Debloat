# Debloat
CREDIT:
Based on original work by Sycnex: https://github.com/Sycnex/Windows10Debloater

DETAILS:
Additions: Silent switches for individual windows 10 debloat options found in the interactive debloat utility. This should allow different MDT environments to utilize each option as requirements dictate. Each interaction has an optional command line replacement.

USAGE:
Debloat_W10_3.ps1 -Silent True/False -Runtype Debloat/Revert -SystemRestore True/False -ForceReboot True/False -RevertDefaultPDF True/False

ADDITIONAL INFORMATION:
The script still has output to the screen for informational purposes. That information could be removed if needed or a future modification would be to dump the output to a log file instead. 

DISCLAIMER:
Run at your own risk. I do not assume any responsibility for damage done to any machine. Please doublecheck the code to make sure it meets your requirements before final implementation.
