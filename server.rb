require './helpers'
require './workers'
require './models'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'secret_sauce'
  set :protection, except: :session_hijacking  
end

helpers Security, Web

## Web site

get "/login" do  
  haml :login, layout: false
end

get "/logout" do
  session.clear
  redirect "/"
end

post "/auth" do
  if user = User[email: params[:email]]
    if user.valid_password? params[:password]
      session[:user] = user.generate_session.uuid
      redirect "/"
    else
      halt 401
    end
  else
    halt 404
  end
end

get "/" do
  require_login
  haml :index
end

get "/users" do
  require_login
  page = params[:page] || 1
  page_size = params[:page_size] || 10
  @users = User.reverse_order(:created_at).paginate(page.to_i, page_size.to_i)
  haml :users
end

get "/users/user/:uuid" do
  require_login
  @selected_user = User[uuid: params[:uuid]]
  haml :"users.view"
end

get "/users/new" do
  require_login
  haml :"users.new"  
end
 
get "/users/edit/:uuid" do
  require_login
  @selected_user = User[uuid: params[:uuid]]
  haml :"users.edit"  
end

get "/users/reset/:uuid" do
  require_login
  @selected_user = User[uuid: params[:uuid]]
  password = make_temporary_password
  SendPasswordReset.new.async.perform params[:email], params[:password]
  redirect "/users/user/#{@selected_user.uuid}"
end

post "/users" do
  require_login
  if user = User[email: params[:email]]
    user.update name: params[:name]  
    if params[:password]
      user.set_password params[:password]
      SendPasswordReset.new.async.perform params[:email], params[:password]
    end          
  else    
    user = User.create name: params[:name], email: params[:email]
    password = make_temporary_password
    user.set_password password
    SendAccountCreated.new.async.perform params[:email], password
  end    
  redirect "/users/user/#{user.uuid}"  
end

get "/users/remove/:uuid" do
  require_login
  selected_user = User[uuid: params[:uuid]]  
  selected_user.destroy
  redirect "/users"
end


## REST APIs


# authenticate a user 
post "/authenticate" do
  if user = User[email: params[:email]]
    if user.valid_password? params[:password]
      user.generate_session.uuid
    else
      halt 401
    end
  else
    halt 404
  end
end

# validate a session
post "/validate" do
  if sesssion = Session[uuid: params[:session]]
    session.user.to_json
  else
    halt 404
  end  
end

# check if user is authorized for a resource
# needs an existing session
post "/check" do
  if sesssion = Session[uuid: params[:session]]
    if session.user.has_resource? params[:resource]
      status 200
    else
      halt 401
    end
  else
    halt 404
  end   
end

# authorize a user to use a resource
# needs an existing session
post "/authorize" do
  if sesssion = Session[uuid: params[:session]]
    if session.user.has_resource? params[:resource]
      status 200
    else
      session.resource.add_resource params[:resource]
      status 200
    end
  else
    halt 404
  end   
  
end