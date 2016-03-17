require 'securerandom'

class Individual < ActiveRecord::Base
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
    elsif i2.given
      return 1
    else
      return 0
    end
    
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
  
  def self.all_by_uid_new
    sql = "select id from individuals where (uid, ver) in (select uid, max(ver) from individuals group by uid) ;"
    res = ActiveRecord::Base.connection.execute(sql)
    array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    Individual.find( array_of_ids )
  end 
  
  def unions_old
    uid_groups = Union.where( "husband_uid = ? OR wife_uid = ?", self.uid, self.uid ).group( :uid )
    union_arr = []
    uid_groups.each do |u|
      union_arr << Union.by_uid( u.uid )
    end
    union_arr
  end

  def unions_new
    sql = "select id, right(uid,5), ver from unions where (uid, ver) in (select uid, max(ver) from unions where (husband_uid = '#{uid}' or wife_uid = '#{uid}') group by uid);"
    res = ActiveRecord::Base.connection.execute(sql)
    array_of_ids = []
    res.each {|r| array_of_ids << r[0]}
    unions = Union.find( array_of_ids )
    unions.sort {|a,b| Event.compare_dates( a.marriage, b.marriage, true ) }
  end
  
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
      
end

