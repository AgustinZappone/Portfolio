/*
 This Java program is used to enhance dictionaries used by Ethical Hackers to test passwords.
 Most used dictionaries contain very weak passwords that no site allows anymore.
 This program uses regex to filter all those passwords with at least 8 characters, one lower case letter, one upper case letter 
 and one number.
 As optional, it can also filter those passwords that also contain at least one special character.
 
 Taking into account that these dictionaries tend to be very large (of many Gigabytes), Java allows us to process the whole file 
 in just seconds.  
  
 */


import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.FileNotFoundException;

public class ReadFile {
	public static void main (String[] args) throws IOException {
		
		FileReader file;
		BufferedReader reader;
		BufferedWriter writer = new BufferedWriter(new FileWriter("output.txt"));
		
		
		try {
			file = new FileReader ("rockyou.txt");
			
			reader = new BufferedReader(file);
			
			String line;
			while((line = reader.readLine()) != null) {
				
				if (line.length() == 8 && line.matches(".*[0-9].*") && line.matches(".*[a-z].*") &&  line.matches(".*[A-Z].*")) //&& line.matches(".*[!#$%&/()=?¡'¿\+*~{},.-;:_|¬°@].*")    
					{
					writer.write(line);
					writer.newLine();			
				}
			}
					
			writer.close();
						
		} 
		
		catch (FileNotFoundException e) {
			System.out.println("Error: " + e.getMessage());
		}
				
	}
	
}
