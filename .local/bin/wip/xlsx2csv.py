import pandas as pd
data_xls = pd.read_excel('excelfile.xlsx', 'Sheet2', dtype=str, index_col=None)
data_xls.to_csv('csvfile.csv', encoding='utf-8', index=False)
