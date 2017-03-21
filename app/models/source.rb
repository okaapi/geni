require 'securerandom'

class Source < ActiveRecord::Base

  def self.new( params = {} )
    if params
      params = params.merge( sid: SecureRandom.uuid )
    else
      params = { sid: SecureRandom.uuid }
    end
    super( params )
  end
  
  def self.titles_for_term( searchterm, is_user )
    terms = searchterm.split(' ')
    sql = ""
	terms.each_with_index do |term,index|
	  sql = sql + "(title LIKE '%#{term}%')"
	  sql = sql + " and "  if index < terms.count-1
    end

    sources = Source.where( sql )
    arr = []
	sources.each do |s|	
	  if is_user
        arr << { title: s.title, sid: s.id }
	  end
    end
    arr 
  end 
  
end
