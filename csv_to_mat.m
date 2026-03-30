% List of CSV files
csv_files = {'11_filtered.csv','12_filtered.csv','21_filter.csv','22_filter.csv','31_filter.csv','32_filter.csv','41_filter.csv','42_filter.csv','51_filt.csv','52_filt.csv','61_filt.csv','62_filt.csv','71.csv', '72.csv', '81.csv', '82.csv', '91.csv', '92.csv', '101.csv', '102.csv', '111.csv', '112.csv', '121.csv', '122.csv'};

for i = 1:length(csv_files)
    % Load each CSV file
    csv_data = readtable(csv_files{i});
    
    % Convert table to array if necessary
    csv_array = table2array(csv_data);
    
    % Save each file with a .mat extension
    mat_filename = [csv_files{i}(1:end-4), '.mat'];  % Replaces .csv with .mat
    save(mat_filename, 'csv_array');
end