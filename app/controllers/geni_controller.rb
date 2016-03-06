class GeniController < ApplicationController

  FONT = 15
  MINFONT = 11
  
  ###################################################################################
  #
  # browse
  #    
  def surnames
    @surnames = Individual.surnames( params[:term]).delete_if { |a| a == '' }
  end
  
  def names
    @surname = params[:surname]
	@term = params[:term]    
	is_user = ( @current_user and ( @current_user.role == 'user' or
                                    @current_user.role == 'admin' ) )
    @names = Individual.names_for_surname( @surname, @term, is_user )     
  end
    
  def tree
    @font = FONT
    @minfont = MINFONT
    @individual = Individual.by_uid( params[:uid] )
  end  
  
  ###################################################################################
  #
  #  edit individual
  #   
  def edit
    @individual = Individual.by_uid( params[:uid] )
  end
  
  def save

    @individual = Individual.by_uid( params[:uid] )  

    @individual.surname = params[:surname]
    @individual.given = params[:given]
    @individual.nickname = params[:nickname]
    @individual.name = @individual.given + ' /' + @individual.surname + '/'
    @individual.prefix = params[:prefix]
    @individual.suffix = params[:suffix]
    @individual.sex = params[:sex]
    @individual.pedigree = params[:pedigree]
    @individual.note = params[:note]
    
    @individual.update_birth( rawdate: params[:Birthdate] ) 
    @individual.update_birth( location: params[:Birthlocation] ) 

    if params[:Deathdate].length > 0 or params[:Deathlocation].length > 0
      @individual.update_death( rawdate: params[:Deathdate] ) 
      @individual.update_death( location: params[:Deathlocation] )
    end 
    
    @individual.user_id = @current_user.id
    @individual.save

    redirect_to tree_path( @individual.uid )
  end
  
  ###################################################################################
  #
  #  add child
  #   
  def new_person
  end
  def create_person
    @individual = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex] )
    @individual.name = @individual.given + ' /' + @individual.surname + '/'    
    @individual.update_birth( rawdate: params[:Birthdate] ) 
    @individual.update_birth( location: params[:Birthlocation] ) 
    @individual.user = @current_user
    @individual.save
    redirect_to tree_path( @individual.uid )    
  end 
      
  ###################################################################################
  #
  #  add child
  #   
  def add_child
    @union = Union.by_uid( params[:uuid] )
    @individual = Individual.by_uid( params[:uid] )   
	@surname = params["surnames-search-txt"]    
  end
  def new_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )  
  end  
  def save_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )
    @child = Individual.by_uid( params[:'names-search-uid'] )
    @child.parents = @union
    @child.user_id = @current_user.id    
    @child.save
    redirect_to tree_path( @individual.uid )    
  end
  def create_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )
    @child = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex], nickname: params[:nickname] )
    @child.name = @child.given + ' /' + @child.surname + '/'    
    @child.update_birth( rawdate: params[:Birthdate] ) 
    @child.update_birth( location: params[:Birthlocation] ) 
    @child.parents = @union
    @child.user_id = @current_user.id
    @child.save
    redirect_to tree_path( @individual.uid )    
  end  
  def remove_child
    @child = Individual.by_uid( params[:uid] )
    @child.parents = nil
    @child.save 
    @parent = Individual.by_uid( params[:puid] )
    redirect_to tree_path( @parent.uid )
  end  
  
  ###################################################################################
  #
  #  add marriage
  #   
  def new_marriage
    @individual = Individual.by_uid( params[:uid] )
	@surname = params["surnames-search-txt"]    
  end
    
  def save_marriage
    @font = FONT
    @minfont = MINFONT
      
    @individual = Individual.by_uid( params[:uid] )
    @spouse = Individual.by_uid( params[:'names-search-uid'] )
    
    # being a bit liberal here 
    fam = Union.create
    if ( @individual.sex and @individual.sex.downcase == 'm' ) or
        ( @spouse and @spouse.sex and @spouse.sex.downcase == 'f' ) 
      fam.husband = @individual
      fam.wife = @spouse if @spouse
    else
      fam.husband = @spouse if @spouse
      fam.wife = @individual
    end
    fam.update_marriage( rawdate: params[:Marriagedate] ) 
    fam.update_marriage( location: params[:Marriagelocation] )     
    fam.save
    
    render action: :tree
  end
  def delete_marriage
    @individual = Individual.by_uid( params[:uid] )
    Union.destroy_all( uid: params[:uuid] )    
    redirect_to tree_path( @individual.uid )
  end
  
  ###################################################################################
  #
  #  search
  #  
  def search    
	@surname = params["surnames-search-txt"]
	@term = params[:term]
	if @surname
      is_user = ( @current_user and ( @current_user.role == 'user' or
                                    @current_user.role == 'admin' ) )	
	  @individuals = Individual.names_for_surname( @surname, @term, is_user )
	end
	render :search
  end
  
  def search_results
    @individual = Individual.by_uid( params[:'names-search-uid'] )
    if @individual
      redirect_to tree_path( @individual.uid )
    else
      redirect_to :search
    end
  end
    
  ###################################################################################
  #
  #  file upload
  #
  def import
    @default_tree = 'wido'       
  end
  
  def file_upload
    ignored = params[ :ignored ]
    
    stored_file = params[:stored_file]  
    if ! stored_file || ! stored_file[:stored_file]      
      flash[:notice] = "Select file to upload first."
      redirect_to :action => :surnames
      return
    end
        
    treename = params[:tree]['name']
	original_file = stored_file[:stored_file].original_filename
    gedfile = stored_file[:stored_file].tempfile.path

    ignored = Import.from_gedfile( treename, gedfile, original_file )
    
    flash[:notice] = ignored
    redirect_to action: :surnames, params: { ignored: ignored }
  end  
    
end
