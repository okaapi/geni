class GeniController < ApplicationController

  def index
    @surnames = Individual.all_surnames
  end
  
  def first_names
    @surname = params[:surname]
    @individuals = Individual.all_given_names( @surname )
  end
  
  def tree
    @font = 15
    @minfont = 10
    @individual = Individual.by_uid( params[:uid] )
    @ignored = params[ :ignored ]
  end
  
  def import
    @default_tree = 'wido'       
  end
  
  def file_upload
    ignored = params[ :ignored ]
    
    stored_file = params[:stored_file]  
    if ! stored_file || ! stored_file[:stored_file]      
      flash[:notice] = "Select file to upload first."
      redirect_to :action => :index
      return
    end
        
    treename = params[:tree]['name']
    gedfile = stored_file[:stored_file].tempfile.path

    ignored = Import.from_gedfile( treename, gedfile )
    
    flash[:notice] = ignored
    redirect_to action: :index, params: { ignored: ignored }
  end  
    
end
