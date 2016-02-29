class Import
  
  def self.from_gedfile( tree_name, gedfile )

	  # 
	  # initialize nodes
	  #
	  mode = submode = nil
	  individual = union = source = nil
	  ignored = "Ignoring all _UID or REFN fields\nOther ignored lines follow:\n"
	  
	  #
	  # initialize crossreferences
	  #
	  indi = {}
	  fam = {}
	  famc = {}
	  husb = Hash.new []
	  wife = Hash.new []
	
	  #not required? 
	  #chil = Hash.new []
	  #fams = Hash.new []
	  #
 
	  # 
	  # open the file!
	  #
	  contents = File.open(gedfile,'r')
	
  
	  Individual.transaction do
	  
	    i = 0
	    contents.each_line do |line|  
	 	      		
	      i += 1      
	      if line =~ /[\d]* _UID/ or line =~ /[\d]* REFN/
	        # ignore
       
	      #
	      #  new block starts
	      #        
	      elsif line =~ /^[^\w\s\d]?0/
	      
	
	        individual.save! if individual
	        union.save! if union
	        source.save! if source
	        individual = union = source = nil       
	        submode = nil
	        if line =~ /[^\w\s\d]0 HEAD/
	          mode = :header  
	          ignored += "Header : " + line        
	        elsif line =~ /^0 @S\d+@ SUBM/
	          mode = :submitter  
	          ignored += "Submitter : " + line  
	        elsif line =~ /^0 @R\d+@ REPO/
	          mode = :repo
	          ignored += "Repo : " + line                              
	        elsif line =~ /^0 @I(\d+)@ INDI/
	          mode = :individual        
	          individual = Individual.create( tree: tree_name )
	          indi[ "@I#{Regexp.last_match(1)}@" ] = individual.uid
	          individual.note = ''   
	          individual.gedraw = line
	          individual.gedfile = gedfile
	        elsif line =~ /0 @F(\d+)@ FAM/
	          mode = :union  
	          union = Union.create( tree: tree_name )
	          fam[ "@F#{Regexp.last_match(1)}@" ] = union.uid
	          union.note = ''   
	          union.gedraw = line
	          union.gedfile = gedfile
	        elsif line =~ /0 @S(\d+)@ SOUR/          
	          mode = :source               
	        end
	     
	      # 
	      #  header is ignored
	      # 
	      elsif mode == :header
	        ignored += "Header : " + line 
	      elsif mode == :submitter
	        ignored += "Submitter : " + line         

        
	      #
	      #  individual!
	      #
	      elsif mode == :individual    
	      
	        individual.gedraw += line
	        if line =~ /^1 NAME (.+)\r/
	          submode = :name 
	          individual.name = Regexp.last_match(1)
	          print '.' if i.modulo(10) == 0
	         
	        elsif line =~ /^1 SEX (.+)\r/
	          submode = :sex
	          individual.sex = Regexp.last_match(1)  
	        elsif line =~ /^1 BIRT/
	          submode = :birth
	        elsif line =~ /^1 OCCU/
	          submode = :note  
	          individual.note += "\n" + 'Occupation: '  
	        elsif line =~ /^1 RESI/
	          submode = :note  
	          individual.note += "\n" + 'Residence: '                       
	        elsif line =~ /^1 ADOP/
	          submode = :note  
	          individual.note += "\n" + 'Adoption: '  
	        elsif line =~ /^1 BAPM/
	          submode = :note  
	          individual.note += "\n" + 'Baptism: ' 
	        elsif line =~ /^1 CHR/
	          submode = :note  
	          individual.note += "\n" + 'Christening: '           
	        elsif line =~ /^1 BURI/
	          submode = :note  
	          individual.note += "\n" + 'Burial: '
	        elsif line =~ /^1 EVEN/
	          submode = :note  
	          individual.note += "\n" + 'Event: '          
	        elsif line =~ /^1 DEAT/                   
	          submode = :death
	        elsif line =~ /^1 FAMC (.+)\r/
	          submode = :child
	          famc[ individual.uid ] = Regexp.last_match(1)
	        elsif line =~ /^1 FAMS (.+)\r/
	          submode = nil        
	          #fams[ individual.uid ] += [Regexp.last_match(1)]             
	        elsif line =~ /^1 CHAN/                   
	          submode = :changed    
	          individual.changed_ged = ''
	        elsif line =~ /^1 NOTE(.*)\r/                 
	          submode = :note  
	          individual.note += "\n" + 'Note: ' + Regexp.last_match(1)    + "\n"         
	        elsif line =~ /^1 SOUR @S(\d+)@\r/                 
	          submode = :source     
	          individual.note += "\n" + "Source: @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"
	
	        #
	        #   submode :name
	        #
	        elsif submode == :name 
	          if line =~ /^2 SURN (.+)\r/
	            individual.surname = Regexp.last_match(1)     
	          elsif line =~ /^2 GIVN (.+)\r/
	            individual.given = Regexp.last_match(1)   
	          elsif line =~ /^2 SURN (.+)\r/
	            individual.surname = Regexp.last_match(1)
	          elsif line =~ /^2 NICK (.+)\r/
	            individual.nickname = Regexp.last_match(1)  
	          elsif line =~ /^2 _AKA (.+)\r/
	            individual.nickname = Regexp.last_match(1)                 
	          elsif line =~ /^2 NPFX (.+)\r/
	            individual.prefix = Regexp.last_match(1)    
	          elsif line =~ /^2 NSFX (.+)\r/
	            individual.suffix = Regexp.last_match(1)  
	          elsif line =~ /^2 _MARNM (.+)\r/
	            individual.note = 'Married name: ' + Regexp.last_match(1) + "\n"                                          
	          else
	            ignored += individual.name + ': ' + line
	          end
	
	                    
	        #
	        #   submode :child  + "\n"  
	        #
	        elsif submode == :child
	          if line =~ /^2 PEDI (.+)\r/
	            individual.pedigree = Regexp.last_match(1)
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end            
	                      
	        #
	        #   submode :death
	        #
	        elsif submode == :death
	          if line =~ /^2 DATE (.+)\r/
	            individual.update_death( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)\r/
	            individual.update_death( location: Regexp.last_match(1) )  
	          elsif line =~ /^2 SOUR @(.+)@\r/
	            individual.note += "\n" + "Death: @#{tree_name}#{Regexp.last_match(1)}@ "     + "\n"         
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end      
	
	        #
	        #   submode :birth
	        #
	        elsif submode == :birth
	          if line =~ /^2 DATE (.+)\r/
	            individual.update_birth( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)\r/
	            individual.update_birth( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@\r/
	            individual.note += "\n" + "Birth: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end
	                    
	        #
	        #   submode :note
	        #
	        elsif submode == :note
	          if line =~ /^1 SOUR @(.+)@\r/
	            individual.note += " @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"     
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end         
	       
	        #
	        #   submode :change
	        #
	        elsif submode == :changed
	          if line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.changed_ged += ' ' + Regexp.last_match(1)  
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end
	
	        #
	        #   submode :source
	        #
	        elsif submode == :source 
	          if line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end
	               
	        else                  
	          ignored += "Ignored #{mode} #{submode}: " + line   
	         
	        end # elsif mode == :individual    
	       
	        
	      #
	      #  union!
	      #
	      elsif mode == :union      
	                       
	        union.gedraw += line
	        if line =~ /^1 MARR/
	          submode = :marriage
	        elsif line =~ /^1 DIV/
	          submode = :divorce   
	          union.divorced = 'Y'            
	        elsif line =~ /^1 HUSB (.+)\r/
	          submode = :husband
	          husb[ union.uid ] = Regexp.last_match(1)
	        elsif line =~ /^1 WIFE (.+)\r/
	          submode = :wife
	          wife[ union.uid ] = Regexp.last_match(1)          
	        elsif line =~ /^1 CHIL (.+)\r/
	          submode = :children 
	          #chil[ union.uid ] += [Regexp.last_match(1)]             
	        elsif line =~ /^1 CHAN/                   
	          submode = :changed    
	          union.changed_ged = ''
	        elsif line =~ /^1 NOTE(.*)\r/                 
	          submode = :note  
	          union.note += "\n" + 'Note: ' + Regexp.last_match(1)    + "\n"         
	        elsif line =~ /^1 SOUR @S(\d+)@\r/                 
	          submode = :source     
	          union.note += "\n" + "Source: @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"
	
	        #
	        #   submode :marriage
	        #
	        elsif submode == :marriage
	          if line =~ /^2 DATE (.+)\r/
	            union.update_marriage( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)\r/
	            union.update_marriage( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@\r/
	            union.note += "\n" + "Birth: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end
	          
	        #
	        #   submode :divorce
	        #
	        elsif submode == :divorce
	          if line =~ /^2 DATE (.+)\r/
	            union.update_divorce( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)\r/
	            union.update_divorce( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@\r/
	            union.note += "\n" + "Birth: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end          
	          
	        #
	        #   submode :note
	        #
	        elsif submode == :note
	          if line =~ /^1 SOUR @(.+)@\r/
	            union.note += " @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"     
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end         
	       
	        #
	        #   submode :change
	        #
	        elsif submode == :changed
	          if line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            union.changed_ged += ' ' + Regexp.last_match(1)  
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end
	
	        #
	        #   submode :source
	        #
	        elsif submode == :source 
	          if line =~ /^[1-5] \w\w\w\w+(.*)\r/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end
	               
	        else                  
	          ignored += "Ignored #{mode} #{submode}: " + line   
	         
	        end # elsif mode == :union
                   
	      #
	      #  source!
	      #
	      elsif mode == :source
                
	      else
	        ignored += "\n" + "\n" + 'PROBLEMS in import.rb'
	        exit
	      end # line =~ /^[^\w\s\d]?0/ ....  :mode
	           
	      
	    end # contents.each_line do |line|  
	
	    
	  end # Individual.transaction do
		
	  Union.transaction do
		print 'wives'
		j = 0
		wife.each do | uid, i |
		  j += 1
		  u = Union.by_uid( uid )
		  w = Individual.by_uid( indi[i] )
		  u.wife = w
		  u.save!
		  print '.' if j.modulo(10) == 0
		end
	  end
	
	  Union.transaction do
		print 'husbands'
		j = 0
		husb.each do | uid, i |
		  j += 1
		  u = Union.by_uid( uid )
		  h = Individual.by_uid( indi[i] )
		  u.husband = h
		  u.save!
		  print '.' if j.modulo(10) == 0
		end
	  end
	
	  Individual.transaction do
		print 'children'
		j = 0
		famc.each do | uid, f |
		  j += 1
		  i = Individual.by_uid( uid )
		  u = Union.by_uid(fam[f])
		  if u
		    i.parents = u
		    i.save!
		  end    
		  print '.' if j.modulo(10) == 0
		end
	  end

      return ignored
      
  end
  
  
end