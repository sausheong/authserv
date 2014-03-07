Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      String :email, size: 255
      String :password
      String :salt
      String :name
    end
    
    create_table :resources do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      String :identifier
    end
    
    create_table :resources_users do
      foreign_key :user_id, :users
      foreign_key :resource_id, :resources
      DateTime :created_at
      index [:user_id, :resource_id], unique: true
    end
    
    create_table :sessions do
      primary_key :id
      String :uuid, unique: true
      DateTime :created_at
      foreign_key :user_id, :users
    end
  end  
end