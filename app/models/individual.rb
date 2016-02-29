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
    self.tstamp = DateTime.now.strftime('%Q')
  end  
  
  def pretty_name( is_user = false )
    birthyear = nil
    if self.birth
      begin
        d = Date.parse( self.birth.date )
        birthyear = d.strftime('%Y').to_i        
      rescue  
        birthyear = self.birth.date.to_i if self.birth.date
      end
    end    

    
    if is_user or self.death
      self.name.gsub( /\//, '')      
    elsif birthyear and birthyear < 1900
      self.name.gsub( /\//, '')    
    else
      n = self.name.gsub( /\//, '').upcase
      n.split(' ').collect { |s| s[0] }.join('. ') + '.'
    end
     
  end
  
  def self.by_uid( uid )
    if uid
      i = Individual.where( uid: uid ).order( tstamp: :asc ).last.dup
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
  
  def self.all_last_names
    uid_groups = Individual.group( :surname ).order( surname: :asc )
    arr = []
    uid_groups.each do |u|
      arr << Individual.by_uid( u.uid )
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

