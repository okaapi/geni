class GeniController < ApplicationController

  def index
    @individuals = Individual.all_last_names
  end
  
  def first_names
    @surname = params[:surname]
    @individuals = Individual.all_given_names( @surname )
  end
  
  def tree
    @font = 15
    @minfont = 10
    @individual = Individual.by_uid( params[:uid] )
  end
  
end
