class Import
  
  def self.from_gedfile( tree_name, gedfile, original_file = nil, log2tt = false )

	  # 
	  # initialize nodes
	  #
	  mode = submode = nil
	  individual = union = source = nil
	  ignored = "Ignoring all _UID, REFN or CHAN fields\nOther ignored lines follow:\n"
	  
	  #
	  # initialize crossreferences
	  #
	  indi = {}
	  fam = {}
	  famc = {}
	  husb = Hash.new []
	  wife = Hash.new []
	  srcs = {}
	  indi_srcs = {}
	  fam_srcs = {}
	  
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

	 	  line.gsub!(/\r/,'')			
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
	        if line =~ /[^\w\s\d]?0 HEAD/
	          mode = :header  
	          ignored += "Header : " + line        
	        elsif line =~ /^0 @SUB\d+@ SUBM/
	          mode = :submitter  
	          ignored += "Submitter : " + line  
	        elsif line =~ /^0 @REPO\d+@ REPO/
	          mode = :repo
	          ignored += "Repo : " + line                              
	        elsif line =~ /^0 @I(\d+)@ INDI/
	          mode = :individual        
	          individual = Individual.create( tree: tree_name )
	          indi[ "@I#{Regexp.last_match(1)}@" ] = individual.uid
	          individual.note = ''   
	          individual.gedraw = line
	          individual.gedfile = original_file
	        elsif line =~ /0 @F(\d+)@ FAM/
	          mode = :union  
	          union = Union.create( tree: tree_name )
	          fam[ "@F#{Regexp.last_match(1)}@" ] = union.uid
	          union.note = ''   
	          union.gedraw = line
	          union.gedfile = original_file
	        elsif line =~ /0 @S(\d+)@ SOUR/          
	          mode = :source  
	          source = Source.create( tree: tree_name )
	          source.title = ''
			  source.content = ''
			  source.gedraw = line
	          source.gedfile = original_file	
			  srcs[Regexp.last_match(1)] = source.sid	

            else
              ignored += line			
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
	        if line =~ /1 NAME (.+)/  # removed trailing \r for Windows
	          submode = :name 
	          individual.name = Regexp.last_match(1)
	          print '.' if log2tt and i.modulo(10) == 0
	        elsif line =~ /^1 SEX (.+)/
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
	        elsif line =~ /^1 FAMC (.+)/ 
	          submode = :child
	          famc[ individual.uid ] = Regexp.last_match(1)
	        elsif line =~ /^1 FAMS (.+)/
	          submode = nil        
	          #fams[ individual.uid ] += [Regexp.last_match(1)]             
	        elsif line =~ /^1 CHAN/                   
	          submode = :changed    
	          #individual.note += "\n" + 'Ged changed: ' 
	        elsif line =~ /^1 NOTE(.*)/                 
	          submode = :note  
	          individual.note += Regexp.last_match(1)    + "\n"         
	        elsif line =~ /^1 SOUR @S(\d+)@/                 
	          submode = :source    
			  ( indi_srcs[ individual.uid ] ||= [] ) << Regexp.last_match(1)
	          #individual.note += "\n" + "Source: @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"
	
	        #
	        #   submode :name
	        #
	        elsif submode == :name 
	          if line =~ /^2 SURN (.+)/ 
	            individual.surname = Regexp.last_match(1)     
	          elsif line =~ /^2 GIVN (.+)/ 
	            individual.given = Regexp.last_match(1)   
	          elsif line =~ /^2 NICK (.+)/
	            individual.nickname = Regexp.last_match(1)  
	          elsif line =~ /^2 _AKA (.+)/
	            individual.nickname = Regexp.last_match(1)                 
	          elsif line =~ /^2 NPFX (.+)/
	            individual.prefix = Regexp.last_match(1)    
	          elsif line =~ /^2 NSFX (.+)/
	            individual.suffix = Regexp.last_match(1)  
	          elsif line =~ /^2 _MARNM (.+)/
	            individual.note = 'Married name: ' + Regexp.last_match(1) + "\n"                                          
	          else
	            ignored += individual.name + ': ' + line
	          end
	
	                    
	        #
	        #   submode :child  + "\n"  
	        #
	        elsif submode == :child
	          if line =~ /^2 PEDI (.+)/
	            individual.pedigree = Regexp.last_match(1)
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end            
	                      
	        #
	        #   submode :death
	        #
	        elsif submode == :death
	          if line =~ /^2 DATE (.+)/
	            individual.update_death( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)/
	            individual.update_death( location: Regexp.last_match(1) )  
	          elsif line =~ /^2 SOUR @(.+)@/
	            individual.note += "\n" + "Death: @#{tree_name}#{Regexp.last_match(1)}@ "     + "\n"         
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end      
	
	        #
	        #   submode :birth
	        #
	        elsif submode == :birth
	          if line =~ /^2 DATE (.+)/ 
	            individual.update_birth( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)/ 
	            individual.update_birth( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@/
	            individual.note += "\n" + "Birth: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line + '|'  
	          end
	                    
	        #
	        #   submode :note
	        #
	        elsif submode == :note
	          if line =~ /^2 SOUR @(.+)@/
	            individual.note += " @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"     
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end         
	       
	        #
	        #   submode :change
	        #
	        elsif submode == :changed
              # ignore
	          
	        #
	        #   submode :source
	        #
	        elsif submode == :source 
	          #if line =~ /^[1-5] \w\w\w\w+(.*)/   
	          #  individual.note += ' ' + Regexp.last_match(1)  + "\n"
	          #else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          #end
	               
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
	        elsif line =~ /^1 HUSB @I(\d+)@/
	          submode = :husband
	          husb[ union.uid ] = "@I#{Regexp.last_match(1)}@"
	        elsif line =~ /^1 WIFE @I(\d+)@/
	          submode = :wife
	          wife[ union.uid ] = "@I#{Regexp.last_match(1)}@"     
	        elsif line =~ /^1 CHIL @I(\d+)@/
	          submode = :children 
	          #chil[ union.uid ] += ["@I#{Regexp.last_match(1)}@"]             
	        elsif line =~ /^1 CHAN/                   
	          submode = :changed    
	          #union.note += "\n" + 'Ged changed: ' 
	        elsif line =~ /^1 NOTE(.*)/                 
	          submode = :note  
	          union.note += Regexp.last_match(1)    + "\n"         
	        elsif line =~ /^1 SOUR @S(\d+)@/                 
	          submode = :source     
	          ( fam_srcs[ union.uid ] ||= [] ) << Regexp.last_match(1)
			  #union.note += "\n" + "Source: @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"
	
	        #
	        #   submode :marriage
	        #
	        elsif submode == :marriage
	          if line =~ /^2 DATE (.+)/
	            union.update_marriage( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)/
	            union.update_marriage( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@/
	            union.note += "\n" + "Marriage: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end
	          
	        #
	        #   submode :divorce
	        #
	        elsif submode == :divorce
	          if line =~ /^2 DATE (.+)/
	            union.update_divorce( rawdate: Regexp.last_match(1) )
	          elsif line =~ /^2 PLAC (.+)/
	            union.update_divorce( location: Regexp.last_match(1) )
	          elsif line =~ /^2 SOUR @(.+)@/
	            union.note += "\n" + "Birth: @#{tree_name}#{Regexp.last_match(1)}@ "       + "\n"       
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line        
	          end          
	          
	        #
	        #   submode :note
	        #
	        elsif submode == :note
	          if line =~ /^2 SOUR @(.+)@/
	            union.note += " @#{tree_name}#{Regexp.last_match(1)}@ "         + "\n"     
	          elsif line =~ /^[1-5] \w\w\w\w+(.*)/   
	            union.note += ' ' + Regexp.last_match(1)  + "\n"
	          else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          end         
	       
	        #
	        #   submode :change
	        #
	        elsif submode == :changed
              # ignore	                   
	
	        #
	        #   submode :source
	        #
	        elsif submode == :source 
	          #if line =~ /^[1-5] \w\w\w\w+(.*)/   
	          #  union.note += ' ' + Regexp.last_match(1)  + "\n"
	          #else
	            ignored += "Ignored #{mode} #{submode}: " + line            
	          #end
	               
	        else                  
	          ignored += "Ignored #{mode} #{submode}: " + line   
	         
	        end # elsif mode == :union
                   
	      #
	      #  source!
	      #
	      elsif mode == :source
                
            source.gedraw += line
	        if line =~ /1 TITL (.+)/  
			  submode = :title
	          source.title = Regexp.last_match(1)
	          print '.' if log2tt and i.modulo(10) == 0
	        elsif line =~ /1 REPO (.+)/  
              #ignore	
	        elsif line =~ /1 AUTH (.+)/  
			  submode = :content	
              source.content += "Author: " + Regexp.last_match(1)  + "\n"			  
	        elsif line =~ /2 CONT(.+)/  
			  submode = :content	
              source.content += Regexp.last_match(1)  + "\n"
	        elsif line =~ /1 NOTE (.+)/  
			  submode = :content	
              source.content += Regexp.last_match(1)  + "\n"			  
	        elsif line =~ /2 CONC (.+)/  
			  if submode == :title
			    source.title += Regexp.last_match(1)
		      elsif submode == :content
			    source.content += Regexp.last_match(1)  + "\n"
		      else
			   ignored += "Ignored #{mode} #{submode}: " + line
			  end			   
	        else
	          ignored += "Ignored #{mode} #{submode}: " + line          
	        end # elsif mode == :source
				
	      else
	        ignored += "PROBLEMS in import.rb"
	        return ignored
	        
	      end # line =~ /^[^\w\s\d]?0/ ....  :mode
	           
	    end # contents.each_line do |line|  
	
	    
	  end # Individual.transaction do
      puts if log2tt 
	  
	  Union.transaction do
		puts 'wives' if log2tt 
		j = 0
		wife.each do | uid, i |
		  j += 1
		  u = Union.by_uid( uid )
		  w = Individual.by_uid( indi[i] )
		  u.wife = w
		  u.save!
		  print '.' if log2tt and j.modulo(10) == 0
		end
	  end
	
	  Union.transaction do
		puts 'husbands' if log2tt
		j = 0
		husb.each do | uid, i |
		  j += 1
		  u = Union.by_uid( uid )
		  h = Individual.by_uid( indi[i] )
		  u.husband = h
		  u.save!
		  print '.' if log2tt and j.modulo(10) == 0
		end
	  end
	
	  Individual.transaction do
		puts 'children' if log2tt
		j = 0
		famc.each do | uid, f |
		  j += 1
		  i = Individual.by_uid( uid )
		  u = Union.by_uid(fam[f])
		  if u
		    i.parents = u
		    i.save!
		  end    
		  print '.' if log2tt and  j.modulo(10) == 0
		end
	  end

	  Individual.transaction do
	  SourceRef.transaction do	  
	    puts 'sources for individuals' if log2tt
	    indi_srcs.each do | uid, sids |
	      sids.each do |sid|
		    individual = Individual.by_uid( uid )
		    source = Source.where( sid: srcs[sid] ).first
            if source and source.content == ''
			  individual.note += "Source: #{source.title} \n"
			  individual.save!
			elsif source
			  sref = SourceRef.create( individual_uid: individual.uid,
                            		   source_id: source.id )
			  sref.save!
			else 
			  # ignore if no source found
			end
		  end
	    end
	  end
	  end	  
	  

	  Union.transaction do
	  SourceRef.transaction do	  
	    puts 'sources for unions' if log2tt
	  
	    fam_srcs.each do | uid, sids |
	      sids.each do |sid|

		    union = Union.by_uid( uid )
		    source = Source.where( sid: srcs[sid] ).first
            if source and source.content == ''
			  union.note += "Source: #{source.title} \n"
			  union.save!
			elsif source
			  sref = SourceRef.create( union_uid: union.uid,
                            		   source_id: source.id )
			else 
			  # ignore if no source found									   
			end
		  end
	    end
	  end
	  end	  

	  Source.transaction do
	    puts 'sources without content' if log2tt
	  
	    srcs.each do | i, sid |		 
          source = Source.where( sid: sid ).first
          if source and source.content == ''
            source.destroy!
		  end
	    end
	  end	  
	  
      return ignored
      
  end
  
  
end
