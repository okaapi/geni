require 'securerandom'

class Individual < ActiveRecord::Base
  belongs_to :birth, class_name: "Event", foreign_key: "birth_id"
  belongs_to :baptism, class_name: "Event", foreign_key: "baptism_id"
  belongs_to :death, class_name: "Event", foreign_key: "death_id"
  belongs_to :adoption, class_name: "Event", foreign_key: "adoption_id"
  belongs_to :burial, class_name: "Event", foreign_key: "burial_id"
  
  def self.new( params = {} )
    if params
      params.merge!( uid: SecureRandom.uuid )
    else
      params = { uid: SecureRandom.uuid }
    end
    super( params )
  end
  
  before_save do
    self.ver = self.ver + 1
  end  
  
  def pretty_name( is_user = false )
     
    if is_user or self.death
      self.name.gsub( /\//, '')      
    elsif self.birth and self.birth.date_as_datetime < Date.new(1915,1,1)
      self.name.gsub( /\//, '')    
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
     
  end
  
  def pretty_first_name( is_user = false )
     
    if is_user or self.death
      self.given || self.pretty_name( is_user ) 
    elsif self.birth and self.birth.date_as_datetime < Date.new(1915,1,1)
      self.given || self.pretty_name( is_user ) 
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
     
  end  
  
  def self.by_uid( uid )
    if uid
      i = Individual.where( uid: uid ).order( ver: :asc ).last.dup
    else
      nil
    end 
  end
    
  def self.all_by_uid
    uid_groups = Individual.group( :uid )
    arr = []
    uid_groups.each do |u|
      arr << Individual.by_uid( u.uid )
    end
    arr
  end
  
  def self.all_surnames
    #uid_groups = Individual.group( :surname ).order( surname: :asc )
    sql = "select surname from individuals where (uid,ver) in " + 
             "(select uid, max(ver) from individuals group by uid)" +
             " group by surname order by surname asc;"
    res = ActiveRecord::Base.connection.execute(sql)
    p res
    arr = []
    res.each do |n|
      if n[0]
        arr << n[0]
      end
    end
    arr
  end  
  
  def self.all_given_names( surname )
    uid_groups = Individual.where( surname: surname ).group( :uid ).order( given: :asc )
    arr = []
    uid_groups.each do |u|
      arr << Individual.by_uid( u.uid )
    end
    arr  
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
  
  def update_baptism( params )
    if self.baptism
      self.baptism = self.baptism.dup
      self.baptism.update_attributes( params )
    else
      self.baptism = Event.new( params )
    end
  end   
  
  def update_adoption( params )
    if self.adoption
      self.adoption = self.adoption.dup
      self.adoption.update_attributes( params )
    else
      self.adoption = Event.new( params )
    end
  end  
  
  def update_burial( params )
    if self.burial
      self.burial = self.burial.dup
      self.burial.update_attributes( params )
    else
      self.burial = Event.new( params )
    end
  end   
  
  def unions
    uid_groups = Union.where( "husband_uid = ? OR wife_uid = ?", self.uid, self.uid ).group( :uid )
    union_arr = []
    uid_groups.each do |u|
      union_arr << Union.by_uid( u.uid )
    end
    union_arr
  end
  
  def parents=( u )
    self.parents_uid = u.uid  
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
 
    
end

