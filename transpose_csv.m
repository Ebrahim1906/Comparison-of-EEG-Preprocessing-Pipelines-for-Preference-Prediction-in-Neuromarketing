% Define the folder path where your CSV files are located
folder_path = 'H:\4-1\Bme 414\Project\my_data'; % Update with your actual directory

% Get a list of all CSV files in the folder
file_list = dir(fullfile(folder_path, '*.csv'));

% Loop over each CSV file
for k = 1:numel(file_list)
    % Load the CSV data, skipping the header
    file_path = fullfile(folder_path, file_list(k).name);
    raw_data = readmatrix(file_path); % Read entire CSV as a matrix

    % Remove the first column
    data_without_first_col = raw_data(:, 2:end); % This keeps columns 2 to 17

    % Transpose the data
    transposed_data = data_without_first_col'; 

    % Generate a new filename for the transposed data
    transposed_filename = fullfile(folder_path, ...
        ['transposed_' file_list(k).name]);

    % Save the transposed data to a new CSV file
    writematrix(transposed_data, transposed_filename);

    disp(['Saved transposed data for ' file_list(k).name ' to ' transposed_filename]);
end
