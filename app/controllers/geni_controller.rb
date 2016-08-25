class GeniController < ApplicationController

  
  ###################################################################################
  #
  # browse & search
  #    
  def surnames
    @surnames = Individual.surnames(params[:term])
  end  
  def names_for_surname
    @surname = params[:surname]
    is_user = @current_user and @current_user.user? 
    @names = Individual.names_for_surname( @surname, is_user )     
  end
  def names_for_term
	@term = params[:term]    	
	if @term.length > 1
	  is_user = @current_user and @current_user.user? 
      @names = Individual.names_for_term( @term, is_user ) 
	end
  end  
  def sources_for_term
	@term = params[:term]    	
	if @term.length > 1
	  is_user = @current_user and @current_user.user? 
      @sources = Source.titles_for_term( @term, is_user ) 
	end
  end  

  ###################################################################################
  #
  # display the tree (as HTML tree or javascript graphics)
  #   
  def display
    #  tree-font is where we start with the fonts
    #  min-tree-font is how far we go down... translates into
    #    tree-depth, one depth increment corresponds to 2 font increments
    #  absolute-min-tree-font is what you think it is
    init_session
	@level = 1
    @maxlevel = session[:'max-level']	
    @font = session[:'tree-font']
    @individual = Individual.by_uid( params[:uid] )     
	if !@individual
	  redirect_to root_path
	elsif session[:display] == "graph"
	  is_user = @current_user and @current_user.user?
	  is_editor = @current_user and @current_user.user?	  
	  @nodes = [] 
	  @edges = []  
	  @nodes << @individual.graph_focus_node( is_user, is_editor )		  
	  @nodes, @edges = @individual.graph_up( 0, @maxlevel, @nodes, @edges, is_user, is_editor )		           
	  @nodes, @edges = @individual.graph_down( 0, @maxlevel, @nodes, @edges, is_user, is_editor )	         
	  render :graph	
	else
	  render
	end
  end  
  
  def detail
    @individual = Individual.by_uid( params[:uid] )
	@sources = @individual.sources  
  end
  
  def depth_change
    init_session
    session[:'max-level'] -= (params[:change].to_i )
    if session[:'max-level'] > session[:'absolute-max-level']
      session[:'max-level'] = session[:'absolute-max-level']
    elsif session[:'max-level'] < 1
      session[:'max-level'] = 1
    end	
    @individual = Individual.by_uid( params[:uid] )
    if @individual 
      redirect_to display_path( @individual.uid )
    else
      redirect_to root_path
    end
  end
  
  def vis_change
    @individual = Individual.by_uid( params[:uid] )
    if session[:display] == "graph"
      session[:display] = "tree"
    else
      session[:display] = "graph"
    end
    if @individual 
      redirect_to display_path( @individual.uid )
    else
      redirect_to root_path
    end
  end
  
  ###################################################################################
  #
  #  edit individual
  #   
  def edit
    @individual = Individual.by_uid( params[:uid] )
    @editable = ( params[:editable] == 'true' )
	@sources = @individual.sources
  end 
  def new_person
    @individual = Individual.new( name: "New Person" )
    @individual.save
	@sources = []
	@editable = true
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

	@source = Source.where( id: params[:'sources-search-sid'] ).first 
	if @source
      sref = SourceRef.create( individual_uid: @individual.uid,
                               source_id: @source.id )
	  sref.save
	end
	
    redirect_to display_path( @individual.uid )
  end

  ###################################################################################
  #
  #  edit union
  #   
  def union_edit	  
    @individual = Individual.by_uid( params[:uid] )
	@union = Union.by_uid( params[:uuid] )
  end
  
  def union_save
	
    @individual = Individual.by_uid( params[:uid] )  
	@union = Union.by_uid( params[:uuid] )
    
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] ) 	
    @union.note = params[:note]
	
    if params[:Divorcedate].length > 0 or params[:Divorcelocation].length > 0
      @union.update_divorce( rawdate: params[:Divorcedate] ) 
      @union.update_divorce( location: params[:Divorcelocation] ) 	
    end 
	
    @union.user_id = @current_user.id
    @union.save

    redirect_to display_path( @individual.uid )
  end
      
  ###################################################################################
  #
  #  add child
  #   
  def add_child
    @union = Union.by_uid( params[:uuid] )
    @individual = Individual.by_uid( params[:uid] )   
    if !@union
      @union = Union.new
      if @individual.female?
        @union.wife_uid = @individual.uid
      else
	    @union.husband_uid = @individual.uid
	  end  
	  @union.save
    end 
  end
  def save_added_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )
    @child = Individual.by_uid( params[:'names-search-uid'] )    
    if @child
      @child.parents = @union
      @child.user_id = @current_user.id    
      @child.save
    end
    redirect_to display_path( @individual.uid )    
  end
  
  def new_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )  
    @gender = params[ :gender ]
    if !@union
      @union = Union.new
      if @individual.female?
        @union.wife_uid = @individual.uid
      else
	    @union.husband_uid = @individual.uid
	  end  
	  @union.save
	end
  end    
  
  def create_new_child
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:n_uuid] )
    @child = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex], nickname: params[:nickname],
               prefix: params[:prefix], suffix: params[:suffix], 
			   pedigree: params[:pedigree] )
			   
    @child.name = @child.given + ' /' + @child.surname + '/'    
    @child.update_birth( rawdate: params[:Birthdate] ) 
    @child.update_birth( location: params[:Birthlocation] ) 
    @child.parents = @union
    @child.user_id = @current_user.id
    @child.save
    redirect_to display_path( @individual.uid )    
  end
    
  def remove_child
    @child = Individual.by_uid( params[:uid] )
    @child.parents_uid = nil
    @child.save 
    @parent = Individual.by_uid( params[:puid] )
    redirect_to display_path( @parent.uid )
  end  
  
  ###################################################################################
  #
  #  add spouse
  #  

  # add existing spouse
  def add_spouse
    @union = Union.by_uid( params[:uuid] )
    @individual = Individual.by_uid( params[:uid] )   
    if !@union
      @union = Union.new
      if @individual.female?
        @union.wife_uid = @individual.uid
      else
	    @union.husband_uid = @individual.uid
	  end      	  
      @union.save      
    end      
  end
  def save_added_spouse
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )
    @spouse = Individual.by_uid( params[:'names-search-uid'] )    	
    if @spouse
      if @union.husband_uid == @individual.uid
	    @union.wife_uid = @spouse.uid
      elsif @union.wife_uid == @individual.uid
	    @union.husband_uid = @spouse.uid
	  end
      @union.save
    end
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] )     
    @union.save
    redirect_to display_path( @individual.uid )    
  end
  
  # create new spouse
  def new_spouse
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )
    if !@union
      @union = Union.new
      if @individual.female?
        @union.wife_uid = @individual.uid
      else
	    @union.husband_uid = @individual.uid
	  end      	  
      @union.save      
    end  
  end    
  def create_new_spouse
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:n_uuid] )    
    @spouse = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex], nickname: params[:nickname],
               prefix: params[:prefix], suffix: params[:suffix], 
			   pedigree: params[:pedigree] )			   
    @spouse.name = @spouse.given + ' /' + @spouse.surname + '/'    
    @spouse.update_birth( rawdate: params[:Birthdate] ) 
    @spouse.update_birth( location: params[:Birthlocation] ) 
	@spouse.save	
    if @union.husband_uid == @individual.uid
      @union.wife_uid = @spouse.uid
    elsif @union.wife_uid == @individual.uid
	  @union.husband_uid = @spouse.uid
	end
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] ) 	  
    @union.save

    redirect_to display_path( @individual.uid )    
  end  
  def remove_spouse
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )	
    if @union.husband_uid == @individual.uid
      @union.husband_uid = nil
	  @union.save
      redirect_to display_path( @union.wife_uid ? @union.wife_uid : @individual.uid )
    elsif @union.wife_uid == @individual.uid
      @union.wife_uid = nil
	  @union.save
      redirect_to display_path( @union.husband_uid ? @union.husband_uid : @individual.uid )
    else
      redirect_to display_path( @individual.uid )
	end	

  end  

  
  ###################################################################################
  #
  #  parents
  #   
  def new_parent
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:uuid] )  
	@sex = params[:sex]
  end    
  def create_new_parent
    @individual = Individual.by_uid( params[:uid] )
    @union = Union.by_uid( params[:n_uuid] )
    @parent = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex], nickname: params[:nickname],
               prefix: params[:prefix], suffix: params[:suffix], 
			   pedigree: params[:pedigree] )			   
    @parent.name = @parent.given + ' /' + @parent.surname + '/'    
    @parent.update_birth( rawdate: params[:Birthdate] ) 
    @parent.update_birth( location: params[:Birthlocation] ) 
	@parent.save
	
	if !@union || !( @individual.parents.uid == @union.uid )
	  @union = Union.new   
	end	
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] ) 		
	if @parent.female?
      @union.wife_uid = @parent.uid
    elsif @parent.male?
	  @union.husband_uid = @parent.uid
	end 	  
    @union.save
	@individual.parents_uid = @union.uid
	@individual.save

    redirect_to display_path( @individual.uid )    
  end  
  
  def remove_parent
    @individual = Individual.by_uid( params[:uid] )
    @parent = Individual.by_uid( params[:puid] )
    @parents = @individual.parents
    if @parents.husband and @parents.husband.uid == @parent.uid
      @parents.husband = nil
    elsif @parents.wife and @parents.wife.uid == @parent.uid
      @parents.wife = nil
    end 
    @parents.save

    if @parents.husband == nil and @parents.wife == nil
      @individual.parents = nil
      @individual.save
    end
    
    redirect_to display_path( @individual.uid )
  end  
  
  ###################################################################################
  #
  #  add marriage
  #
=begin     
  def marriage_existing
    @individual = Individual.by_uid( params[:uid] )
  end
    
  def save_marriage_existing
  
    @individual = Individual.by_uid( params[:uid] )
    @spouse = Individual.by_uid( params[:'names-search-uid'] )
    
    # being a bit liberal here 
    @union = Union.create
    if ( @individual.sex and @individual.sex.downcase == 'm' ) or
        ( @spouse and @spouse.sex and @spouse.sex.downcase == 'f' ) 
      @union.husband = @individual
      @union.wife = @spouse if @spouse
    else
      @union.husband = @spouse if @spouse
      @union.wife = @individual
    end
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] )     
    @union.save
    
    redirect_to display_path( @individual.uid )
  end
  
  def marriage_new
    @individual = Individual.by_uid( params[:uid] )
  end
    
  def save_marriage_new

    @individual = Individual.by_uid( params[:uid] )
    @spouse = Individual.new( given: params[:given], surname: params[:surname], 
               sex: params[:sex], nickname: params[:nickname],
               prefix: params[:prefix], suffix: params[:suffix], 
			   pedigree: params[:pedigree] )	   
    @spouse.name = @spouse.given + ' /' + @spouse.surname + '/'    
    @spouse.update_birth( rawdate: params[:Birthdate] ) 
    @spouse.update_birth( location: params[:Birthlocation] ) 
	@spouse.save	
    
    # being a bit liberal here 
    @union = Union.create
    if ( @individual.sex and @individual.sex.downcase == 'm' ) or
        ( @spouse and @spouse.sex and @spouse.sex.downcase == 'f' ) 
      @union.husband = @individual
      @union.wife = @spouse if @spouse
    else
      @union.husband = @spouse if @spouse
      @union.wife = @individual
    end
    @union.update_marriage( rawdate: params[:Marriagedate] ) 
    @union.update_marriage( location: params[:Marriagelocation] )     
    @union.save
    
    redirect_to display_path( @individual.uid )
  end  

  def delete_marriage
    @individual = Individual.by_uid( params[:uid] )
    Union.destroy_all( uid: params[:uuid] )    
    redirect_to display_path( @individual.uid )
  end
=end  
  
  ###################################################################################
  #
  #  edit source
  #   
  def source_edit
    if params[:sid]
      @source = Source.where( id: params[:sid] ).first
	else
	  @source = Source.create
	  @source.save
	end
  end   
  def source_save
    @source = Source.where( id: params[:sid] ).first

	@source.title = params[:title]
	@source.content = params[:content]
	@source.save
    redirect_to source_edit_path( @source.id )
  end
  def source_content
    @source = Source.where( id: params[:sid] ).first
  end
  def source_delete
    @source = Source.where( id: params[:sid] ).first
    @individual = Individual.by_uid( params[:uid] )  
	SourceRef.destroy_all( individual_uid: @individual.uid, source_id: @source.id )
    redirect_to display_path( @individual.uid )	
  end	
  
  ###################################################################################
  #
  #  search
  #  
  
  def search_results
    @individual = Individual.by_uid( params[:'names-search-uid'] )
    if @individual
      redirect_to display_path( @individual.uid )
    else
      redirect_to :search
    end
  end
    
  ###################################################################################
  #
  #  file upload
  #
  def import
    @default_tree = 'new-tree'       
  end
  
  def file_upload
          
    treename = params[ :tree ]
    file = params[:file]  

    if ! file   
      flash[:notice] = "Select file to upload first."
      redirect_to root_path
      return
    end

	original_file = file.original_filename
    gedfile = file.tempfile.path

    ignored = Import.from_gedfile( treename, gedfile, original_file )
    
    flash[:notice] = ignored
    
    redirect_to root_path
  end  
  
  private
  
  ###################################################################################
  #
  #  initialize session with defaults
  #  
  def init_session
    session[:'tree-font'] ||= 15
	session[:'max-level'] ||= 2
	session[:'absolute-max-level'] = 4
	session[:display] ||= "graph"
  end
    
end
