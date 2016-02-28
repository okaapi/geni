class ImportController < ApplicationController

  def index
    @default_tree = 'wido'
    @ignored = params[:ignored]
  end
  
  def file_upload

    individuals = []
    families = []
    
    stored_file = params[:stored_file]  
    if ! stored_file || ! stored_file[:stored_file]      
      flash[:notice] = "Select file to upload first."
      redirect_to :action => :index
      return
    end
    #tree_name = params[:tree]['name']

    puts 'START@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'     
    i = 0
    mode = submode = nil
    individual = nil
    ignored = ''
    contents = stored_file[:stored_file].tempfile.read 
    contents.each_line do |line|  
      
      puts 'begin loop v'
      i += 1  
      puts line
      if line =~ /0 HEAD/
        mode = :header
        submode = nil        
      elsif line =~ /0 @I\d+@ INDI/
        mode = :individual
        individual = Individual.create
        submode = nil
        p individual       
      elsif line =~ /0 @F\d+@ FAM/
        mode = :family  
        submode = nil        
        puts 'family'       
      elsif line =~ /0 @S\d+@ SOUR/
        mode = :source  
        submode = nil        
        puts 'source'
      elsif mode == :header
        ignored += 'Header ' + line
      elsif mode == :individual    
        p individual
        p submode
        if line =~ /1 NAME (.+)\r/
          submode = :name 
          individual.name = Regexp.last_match(1)
        elsif line =~ /1 SEX (.+)\r/
          submode = :sex
          individual.sex = Regexp.last_match(1)  
        elsif line =~ /1 BIRT (.+)\r/
          submode = :birth
          event = Event.new( date: Regexp.last_match(1) )  
        elsif line =~ /1 BAPM (.+)\r/
          ignored += individual.name + ': ' + line
        elsif line =~ /1 DEAT (.+)\r/                   
          submode = :death
          event = Event.new( date: Regexp.last_match(1) )        
        elsif submode == :name and line =~ /2 SURN (.+)\r/
          individual.surname = Regexp.last_match(1)     
        elsif submode == :name and line =~ /2 GIVN (.+)\r/
          individual.given = Regexp.last_match(1)   
        elsif submode == :name and line =~ /2 SURN (.+)\r/
          individual.surname = Regexp.last_match(1)                          
        end
      else
        puts 'STOP@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        redirect_to :action => :index, :ignored => ignored
        return        
      end
      puts 'end loop ^'
      
      if i > 30
        puts 'RETURN@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'
        redirect_to :action => :index, :ignored => ignored
        return 
      end
           
    end

    redirect_to :action => :index  
  end  
  
end
