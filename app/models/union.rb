require 'date'

class UnionValidator < ActiveModel::Validator
  def validate(record)
    if ( record.husband_uid == record.wife_uid and record.husband_uid != nil )
      record.errors[:base] << "can't have same person be husband and wife"
    end
  end
end

class Union < ActiveRecord::Base
  validates_with UnionValidator
  belongs_to :marriage, class_name: "Event", foreign_key: "marriage_id"
  belongs_to :divorce, class_name: "Event", foreign_key: "divorce_id"
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
  
  def self.by_uid( uid )
    u = Union.where( uid: uid ).order( ver: :asc ).last
    if u
      udup = u.dup
      udup.updated_at = u.updated_at
      udup 
    else
      nil
    end
  end
  
  def update_divorce( params )
    if self.divorce
      self.divorce = self.divorce.dup
      self.divorce.update_attributes( params )
    else
      self.divorce = Event.new( params )
    end
  end
  
  def update_marriage( params )
    if self.marriage
      self.marriage = self.marriage.dup
      self.marriage.update_attributes( params )
    else
      self.marriage = Event.new( params )
    end
  end
    
  def husband=( h )
    self.husband_uid = h ? h.uid : nil
  end
  
  def husband
    Individual.by_uid( self.husband_uid )
  end
  
  def wife=( h )
    self.wife_uid = h ? h.uid : nil
  end
  
  def wife
    Individual.by_uid( self.wife_uid )
  end
  
  def self.all_by_uid
    uid_groups = Union.group( :uid )    
    arr = []
    uid_groups.each do |u|
      arr << Union.by_uid( u.uid )
    end    
    arr
  end
    
  def children
    # this might pull uids who in the past had this value of parents_uid
    # so need to check in the == statement below
    uid_groups = Individual.where( parents_uid: self.uid ).group( :uid )
    child_arr = []
    uid_groups.each do |u|
      i = Individual.by_uid( u.uid )
      if( i.parents_uid == self.uid )
        child_arr << i
      end
    end
    child_arr.sort! { |a,b| a.name <=> b.name }    
    child_arr.sort! { |a,b| sort_by_birth_date( a, b ) }
  end
  
  def spouse( uid )
    if husband_uid == uid
      Individual.by_uid( wife_uid )
    elsif wife_uid == uid
      Individual.by_uid( husband_uid )
    else
      nil
    end
  end
  
  def sources
    srefs = SourceRef.where( union_uid: self.uid ) 
    srcs = []		
    srefs.each { |sref| srcs << Source.where( id: sref.source_id ).first }
    srcs.uniq
  end		
    
  private
  
  def sort_by_birth_date( a, b )
    adate = a.birth ? a.birth.date : ''
    bdate = b.birth ? b.birth.date : ''
    begin apdate = Date.parse( adate ) rescue apdate = '' end 
    begin bpdate = Date.parse( bdate ) rescue bpdate = '' end 
    if apdate.class == bpdate.class
      apdate <=> bpdate
    else
      0
    end       
  end
  
end
