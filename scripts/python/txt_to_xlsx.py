import pandas as pd
import sys
import os

def txt_to_xlsx(txt_file, xlsx_file=None):
    """
    Convert a TXT file to XLSX format.
    
    Args:
        txt_file: Path to the input TXT file
        xlsx_file: Path to the output XLSX file (optional)
                   If not provided, uses the same name as TXT with .xlsx extension
        delimiter: Delimiter used in the TXT file (default: tab)
    """
    try:
        # Check if input file exists
        if not os.path.exists(txt_file):
            print(f"Error: File '{txt_file}' not found.")
            return False
        
        # Generate output filename if not provided
        if xlsx_file is None:
            xlsx_file = os.path.splitext(txt_file)[0] + '.xlsx'
        
        # Ensure output file has .xlsx extension
        if not xlsx_file.endswith('.xlsx'):
            xlsx_file = os.path.splitext(xlsx_file)[0] + '.xlsx'
        
        # Read the TXT file with explicit tab delimiter
        print(f"Reading TXT file: {txt_file}")
        
        # Read with explicit parameters
        df = pd.read_csv(
            txt_file, 
            sep='\t',
            engine='python',
            encoding='utf-8'
        )
        
        cols = list(df.columns)
        if cols and cols[0].startswith('#'):
            cols[0] = cols[0].lstrip('#')
            df.columns = cols
            
        print(f"Detected {len(df.columns)} columns and {len(df)} rows")
        print(f"Column names: {list(df.columns)}")
        
        # Write to XLSX file
        print(f"Writing to XLSX file: {xlsx_file}")
        df.to_excel(xlsx_file, index=False, engine='openpyxl')
        
        print(f"Successfully converted '{txt_file}' to '{xlsx_file}'")
        return True
        
    except Exception as e:
        print(f"Error during conversion: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    # Check command line arguments
    if len(sys.argv) < 2:
        print("Usage: python txt_to_xlsx.py <input.txt> [output.xlsx]")
        sys.exit(1)
    
    txt_file = sys.argv[1]
    xlsx_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    txt_to_xlsx(txt_file, xlsx_file)