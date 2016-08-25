require 'securerandom'

class IndividualValidator < ActiveModel::Validator
  def validate(record)
    if ( !record.name or record.name == '' ) and 
       ( !record.given or record.given == '' ) and 
       ( !record.surname or record.surname == '' )
      record.errors[:base] << "Need either name or given name or surname."
    end
  end
end

class Individual < ActiveRecord::Base
  validates_with IndividualValidator
  belongs_to :birth, class_name: "Event", foreign_key: "birth_id"
  belongs_to :death, class_name: "Event", foreign_key: "death_id"
  belongs_to :user
  
  def self.new( params = {} )
    if params
      params.merge!( uid: SecureRandom.uuid )
    else
      params = { uid: SecureRandom.uuid }
    end
    super( params )
  end
  
  before_save do
    self.updated_at = nil
    self.ver = self.ver + 1
  end  
  
  def living?
    if self.death
      false
    elsif self.birth and self.birth.date and ( self.birth.date_as_datetime < Date.new(1900,1,1) )
      false
    else
      true
    end
  end
  
  def pretty_name( is_user = false )
     
    if is_user or !self.living?
      self.name.gsub( /\//, '')   
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
     
  end
  
  def pretty_name_multiline( is_user = false )

    if is_user or !self.living?
      p = self.given ? (self.given.split(' ')[0] +'\n') : ''
      p = p + self.surname + '\n' if self.surname and self.surname.length > 0
      p = p + ( (self.birth and self.birth.year) ? self.birth.year : '' ) 
      p = p + ( (self.death and self.death.year) ? '-' + self.death.year : '' )       
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
	
  end
  
  def pretty_first_name( is_user = false )
     
    if is_user or !self.living?
      self.given || self.pretty_name( is_user ) 
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
     
  end  
  
  def male?
    sex.downcase == 'm'
  end
  def female?
    sex.downcase == 'f'
  end
  
  def self.by_uid( uid )
    
    if uid
      i = Individual.where( uid: uid ).order( ver: :asc ).last
      if i
        idup = i.dup
        idup.updated_at = i.updated_at
        idup 
      else
        nil
      end
    else
      nil
    end 
  end
    
  def self.all_by_uid
    self.all_by_uid_old
  end  
  
  def self.surnames( term = '' )
    sql = "select surname from individuals where surname like \"#{term}%\" group by surname"
    res = ActiveRecord::Base.connection.execute(sql)
    arr = []
    res.each do |n|
      if n[0]
        arr << n[0]
      end
    end
    arr
  end  

  def self.names_for_surname( surname, is_user)
    self.names_for_surname_old( surname, is_user )
  end

  def self.names_for_term( searchterm, is_user )
    self.names_for_term_old( searchterm, is_user )
  end
  
  def update_death( params )
    if self.death
      self.death = self.death.dup
      self.death.update_attributes( params )
    else
      self.death = Event.new( params )
    end
  end
  
  def update_birth( params )
    if self.birth
      self.birth = self.birth.dup
      self.birth.update_attributes( params )
    else
      self.birth = Event.new( params )
    end
  end  
 
  def unions
    unions_old
  end
  
  def parents=( u )
    self.parents_uid = u ? u.uid : nil  
  end
  
  def parents
    Union.by_uid( self.parents_uid )
  end
  def father
    u = Union.by_uid( self.parents_uid )
    u ? Individual.by_uid( u.husband_uid ) : nil
  end  
  def mother
    u = Union.by_uid( self.parents_uid )
    u ? Individual.by_uid( u.wife_uid ) : nil
  end   
  def is_my_child?( child )
    if child and child.father and child.father.uid == self.uid 
      true
    elsif child and child.mother and child.mother.uid == self.uid
      true
    else
      false
    end
  end
  
  def self.compare_names( i1, i2, order )
    
    if ( i1.surname and i2.surname and i1.surname == i2.surname ) or
           ( !i2.surname and !i1.surname ) 
        if i1.given and i2.given
          return i1.given.downcase <=> i2.given.downcase
        elsif i1.given
          return -1
        elsif i2.given
          return 1
        else
          return 0
        end
    elsif i1.surname and i2.surname
        return ( order ? i1.surname.downcase <=> i2.surname.downcase : 
                         i2.surname.downcase <=> i1.surname.downcase )
    elsif i1.surname
      return -1
    elsif i2.surname
      return 1
    end #  else is not possible...  if both surnames don't exist, first clause hits
    
  end
 
  def sources
    srefs = SourceRef.where( individual_uid: self.uid ) 
    srcs = []		
    srefs.each { |sref| srcs << Source.where( id: sref.source_id ).first }
    srcs.uniq
  end
   
  #
  #  these should be private, this is for testing
  #
  
  def self.all_by_uid_old  
    uid_groups = Individual.group( :uid )
    arr = []
    uid_groups.each do |u|
      arr << Individual.by_uid( u.uid )
    end
    arr
  end
  
=begin  
  def self.all_by_uid_new
    sql = "select id from individuals where (uid, ver) in (select uid, max(ver) from individuals group by uid) ;"
    res = ActiveRecord::Base.connection.execute(sql)
    array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    Individual.find( array_of_ids )
  end 
=end
  
  def unions_old
    uid_groups = Union.where( "husband_uid = ? OR wife_uid = ?", self.uid, self.uid ).group( :uid )
    union_arr = []
    uid_groups.each do |u|
      union = Union.by_uid( u.uid )
      if ( union.husband and union.husband.uid == self.uid ) or 
         ( union.wife and union.wife.uid == self.uid )
        union_arr << union
      end
    end
    union_arr
  end

=begin
  def unions_new
    sql = "select id, right(uid,5), ver from unions where (uid, ver) in (select uid, max(ver) from unions where (husband_uid = '#{uid}' or wife_uid = '#{uid}') group by uid);"
    res = ActiveRecord::Base.connection.execute(sql)
    array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    unions = Union.find( array_of_ids )
    unions.sort {|a,b| Event.compare_dates( a.marriage, b.marriage, true ) }
  end
=end
  
  def self.names_for_surname_old( surname, is_user )
    uid_groups = Individual.where( surname: surname ).group( :uid ).order( given: :asc )
    arr = []	
    uid_groups.each do |u|
	  indi = Individual.by_uid( u.uid )
	  given = indi.pretty_first_name( is_user )
      arr << { fullname: indi.pretty_name( is_user ), given: given, 
	           uid: indi.uid, birth: ( (indi.birth ? indi.birth.date : '' ) || '' ), ver: indi.ver }
    end
    arr  
  end
  
=begin  
  def self.names_for_surname_new( surname, is_user )
    sql = "select id, right(uid,5), ver from individuals where (uid, ver) in (select uid, max(ver) from individuals where surname = '#{surname}' group by uid) order by given, ver ASC;"
    res = ActiveRecord::Base.connection.execute(sql)
    array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    indis = Individual.find( array_of_ids )
    indis.sort! {|a,b| a.given <=> b.given }
	arr = []
    indis.each do |indi|
      arr << { fullname: indi.pretty_name( is_user ), given: indi.pretty_first_name( is_user ), 
	           uid: indi.uid, birth: ( (indi.birth ? indi.birth.date : '' ) || '' ), ver: indi.ver }
 	end
    arr  
  end
=end
    
  def self.names_for_term_old( searchterm, is_user )
    terms = searchterm.split(' ')
    sql = ""
	terms.each_with_index do |term,index|
	  sql = sql + "(surname LIKE '%#{term}%' or given LIKE '%#{term}%')"
	  sql = sql + " and "  if index < terms.count-1
    end

    uid_groups = Individual.where( sql ).group( :uid ).order( given: :asc )
    arr = []
	uid_groups.each do |u|	
	  indi = Individual.by_uid( u.uid )
	  if !indi.living? || is_user
        arr << { fullname: indi.pretty_name( is_user ), given: indi.pretty_first_name( is_user ), 
	           ver: indi.ver,
	           uid: indi.uid, birth: ( (indi.birth ? indi.birth.date : '' ) || '' ) }
	  end
    end
    arr 
  end  

=begin  
  def self.names_for_term_new( searchterm, is_user )
    terms = searchterm.split(' ')
    search_sql = ""
	terms.each_with_index do |term,index|
	  search_sql = search_sql + "(surname LIKE '%#{term}%' or given LIKE '%#{term}%')"
	  search_sql = search_sql + " and "  if index < terms.count-1
    end
	
	sql = "select id, right(uid,5), ver from individuals where (uid, ver) in (select uid, max(ver) from individuals where (#{search_sql}) group by uid) order by given, ver ASC;"
    res = ActiveRecord::Base.connection.execute(sql)
	array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    indis = Individual.find( array_of_ids )
    indis.sort! {|a,b| (a.given ? a.given : '') <=> (b.given ? b.given : '') }
	arr = []
    indis.each do |indi|
	  if !indi.living? || is_user
        arr << { fullname: indi.pretty_name( is_user ), given: indi.pretty_first_name( is_user ), 
	             ver: indi.ver,
	             uid: indi.uid, birth: ( (indi.birth ? indi.birth.date : '' ) || '' ) }
      end
    end
    arr  
  end
=end


  #
  #
  #  graphing code... recursive...  for the "tree" display, recursion is in the html itself
  #
  #
  #
  def graph_focus_node( is_user, is_editor )
	if is_editor
	  node = { id: self.uid, group: (self.male? ? "guys" : "gals"), level: 0,
	         label: self.pretty_name_multiline( is_user ), 
	         title: 'double click to edit',
	         current: true }
	else
	  node = { id: self.uid, group: (self.male? ? "guys" : "gals"), level: 0,
	         label: self.pretty_name_multiline( is_user ), 
	         title: 'double click for details',
	         current: true }
	end  
	node
  end
  
  def graph_up( level, maxlevel, nodes, edges, is_user, is_editor )
  
    if level < maxlevel
    
	  if ( par = self.parents )		  
	    par_id = 'NIL/' + par.uid	
        nodes << { id: par_id, group: "unions", level: level + 1, 
                   label: (par.marriage.date if par.marriage) }
	    edges << { from: par_id, to: self.uid, id: 'NIL/' + self.uid  }
	  elsif level == 0 and is_editor
	    par = Union.new
	    par_id = 'NIL/' + par.uid		    
        nodes << { id: par_id, group: "newunion", level: level + 1, 
                   label: (par.marriage.date if par.marriage) }
	    edges << { from: par_id, to: self.uid, id: 'NIL/' + self.uid  }	    
	  end
	  
	  if par
	    
	    if ( fath = par.husband )
		  nodes, edges = fath.graph_up( level + 2, maxlevel, nodes, edges, is_user, is_editor )
	      nodes << { id: fath.uid, group: "guys", level: level + 2, 
	                 label: fath.pretty_name_multiline( is_user ) }
	      if level == 0 and is_editor
            edges << { from: fath.uid, to: par_id, id: 'CONF/remove_parent/' + self.uid + '/' + fath.uid,
	                   title: 'double click to remove parent' }
	      else
            edges << { from: fath.uid, to: par_id, id: 'NIL/' + self.uid + '/' + fath.uid }	      
	      end
	    elsif level == 0 and is_editor
	      ident = 'XHR/new_parent/' + self.uid + '/m/' + par.uid
	      nodes << { id: ident,     
	                 group: 'newperson', level: +2,
	                 label: 'add father',
	                 title: 'double click to add father' }	                 
	      edges << { from: ident, to: par_id, id: ident, title: 'double click to add father' }	
	    end
        	
	    if ( moth = par.wife )
		  nodes, edges = moth.graph_up( level + 2, maxlevel, nodes, edges, is_user, is_editor )
	      nodes << { id: moth.uid, group: "gals", level: level + 2, 
	                 label: moth.pretty_name_multiline( is_user ) }
	      if level == 0 and is_editor             
	        edges << { from: moth.uid, to: par_id, id: 'CONF/remove_parent/' + self.uid + '/' + moth.uid,
	                   title: 'double click to remove parent' }
	      else
	        edges << { from: moth.uid, to: par_id, id: 'NIL/' + self.uid + '/' + moth.uid }
	      end
	      
	    elsif level == 0 and is_editor
	      ident = 'XHR/new_parent/' + self.uid + '/f/' + par.uid
	      nodes << { id: ident,     
	                 group: 'newperson', level: +2,
	                 label: 'add mother',
	                 title: 'double click to add mother' }	                 
	      edges << { from: ident, to: par_id, id: ident, title: 'double click to add mother' }		      	      
	    end	
		
	  end
	end
 
	return nodes, edges
  
  end
  
  def graph_down( level, maxlevel, nodes, edges, is_user, is_editor )
  
    if level > - maxlevel

      unions = self.unions
      if level == 0 and is_editor
        newunion = Union.new
        newunion_uid = newunion.uid
        unions << newunion
      end  
      
      unions.each do |unio|
        
        if level == 0 and is_editor
          if unio.uid != newunion_uid
            unio_id = 'XHR/union_edit/' +  unio.uid + '/' + self.uid
	        nodes << { id: unio_id, group: "unions", level: level -1, 
	                   label: (unio.marriage.year if unio.marriage), 
	                   title: 'double click to edit marriage data' }
	      else
            unio_id = 'XHR/union_edit/' +  unio.uid + '/' + self.uid
	        nodes << { id: unio_id, group: "newunion", level: level -1 }	      
	      end	       
	      if unio.husband_uid == self.uid or unio.wife_uid == self.uid	
	        edges << { from: self.uid, to: unio_id, id: 'CONF/remove_spouse/' + self.uid + '/' + unio.uid,
	                   title: 'double click to remove' }
	      else
	        edges << { from: self.uid, to: unio_id, id: 'NIL/' + self.uid + '/' + unio.uid }
	      end    	                                        
        else
          unio_id = 'NIL/' + unio.uid
	      nodes << { id: unio_id, group: "unions", level: level -1, 
	                 label: (unio.marriage.year if unio.marriage) }   
	      edges << { from: self.uid, to: unio_id, id: 'NIL/' + self.uid + '/' + unio.uid }    	                        
        end

	    
	    if (spou = unio.spouse( self.uid ) )
	      gen = ( spou.male? ? "guys" : "gals")	   
	      nodes << { id: spou.uid, group: gen, level: level , 
	                 label: spou.pretty_name_multiline( is_user ) }
	      if level == 0 and is_editor
	        edges << { from: spou.uid, to: unio_id, id: 'CONF/remove_spouse/' + spou.uid + '/' + unio.uid,
	                   title: 'double click to remove from marriage' }
	      else
	        edges << { from: spou.uid, to: unio_id, id: 'NIL/' + spou.uid + '/' + unio.uid }	      
	      end
	    elsif level == 0 and is_editor
	      node_ident = 'XHR/new_spouse/' + self.uid + '/' + unio.uid 
	      edge_ident = 'XHR/new_spouse/' + self.uid + '/' + unio.uid 
	      nodes << { id: node_ident,     
	                 group: 'newperson', level: 0,
	                 label: 'add spouse',
	                 title: 'double click to add spouse' }	                 
	      edges << { from: unio_id, to: node_ident, id: edge_ident, title: 'double click to add spouse' }	      	      	    
	    end	  
	    	    
	    unio.children.each do |chil|
	    	      
	      gen = ( chil.male? ? "guys" : "gals")	      
	      nodes << { id: chil.uid, group: gen, 
	                 level: level -2, 
	                 label: chil.pretty_name_multiline( is_user ) }
	      if level == 0 and is_editor
	        edges << { from: unio_id, to: chil.uid, id: 'CONF/remove_child/' + chil.uid + '/' + self.uid,
	                   title: 'double click to remove child' }
	      else
	        edges << { from: unio_id, to: chil.uid, id: 'NIL/' + chil.uid + '/' + self.uid }
	      end	                   
	      nodes, edges = chil.graph_down( level - 2, maxlevel, nodes, edges, is_user, is_editor )
	      	      	      
	    end	 
	    
	    if level == 0 and is_editor
	      node_ident = 'XHR/new_child/' + self.uid + '/' + unio.uid + '?gender=F'
	      edge_ident = 'XHR/new_child/' + self.uid + '/' + unio.uid + '?gender=M'
	      nodes << { id: node_ident,     
	                 group: 'newperson', level: -2,
	                 label: 'add',
	                 title: 'double click to add new child' }	                 
	      edges << { from: unio_id, to: node_ident, id: edge_ident, title: 'double click to add new child' }
	    end 
		
	  end
	end

	return nodes, edges
  
  end  
      
end

