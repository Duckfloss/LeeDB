def unzip(file)
	Zip::File.open(file) do |zip_file|
		# Handle entries one by one
		zip_file.each do |entry|
			# Extract to file/directory/symlink
			puts "Extracting #{entry.name}"
		end
	end
end

def dothething

# get a list of files from $dir






end
