**free

// control options
ctl-opt PGMINFO(*PCML : *MODULE);
ctl-opt nomain;
ctl-opt decedit('0,') datedit(*DMY/);
ctl-opt option(*srcstmt : *nodebugio);
ctl-opt bnddir('APPBNDDIR');

/include qproto,PROG1

//-----------------------------------------------
// Get all users
//-----------------------------------------------

dcl-proc USERSRV_GetAllUsers export;
    dcl-pi USERSRV_GetAllUsers;
        jsonString varchar(30000);
        response varchar(30000);
    end-pi;

    // get all users from database
    exec sql
        select json_object('users' value json_arrayagg(
        json_object('id' value id,
                    'name' value json_object('first' value firstname,
                                             'last'  value lastname),
                    'email' value email,
                    'phone' value phone,
                    'email_verified_at' value email_verified_at,
                    'password' value password,
                    'remember_token' value remember_token,
                    'created_at' value created_at,
                    'updated_at' value updated_at)))
        into :response
        from TOOLSHOP_DEV.users;
   //dump json in logging table
   exec sql
       insert into TOOLSHOP_DEV.JSONLOG_USERS(json, created_at)
       values(:response, CURRENT_TIMESTAMP);


end-proc;

dcl-proc USERSRV_CreateUser export;
    dcl-pi USERSRV_CreateUser;
        jsonString varchar(30000);
        response varchar(30000);
    end-pi;

    //create vars for user cols
    dcl-s firstName varchar(50);
    dcl-s lastName varchar(50);
    dcl-s email varchar(255);
    dcl-s phone varchar(255);
    dcl-s email_verified_at date(*iso);
    dcl-s password varchar(255);
    dcl-s remember_token varchar(100);

    exec sql
        select jt.firstname, jt.lastname, jt.email, jt.phone, jt.email_verified_at,
            jt.passwordt, jt.remember_token
        into :firstName, :lastName, :email, :phone, :email_verified_at, :password, :remember_token

        from json_table(:jsonString,
                        '$'
                         columns(firstname         varchar(50)  path 'lax $.name.first',
                                 lastname          varchar(50)  path 'lax $.name.last',
                                 email             varchar(255) path 'lax $.email',
                                 phone             varchar(255) path 'lax $.phone',
                                 email_verified_at date         path 'lax $.email_verified_at',
                                 passwordt         varchar(255) path 'lax $.password',
                                 remember_token    varchar(100) path 'lax $.remember_token'
                         )) as jt;


    //fill vars with json
    //create user in db

    exec sql
      insert into TOOLSHOP_DEV.users(firstname, lastname, email, phone,
                                     email_verified_at, password, remember_token,
                                     created_at, updated_at)
      values(:firstName, :lastName, :email, :phone, :email_verified_at, :password,
             :remember_token, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

   return;
end-proc;

dcl-proc USERSRV_UpdateUser export;
    dcl-pi USERSRV_UpdateUser;
      jsonString varchar(30000);
      response varchar(30000);

    end-pi;

    dcl-s email_verified_at date(*iso);
    dcl-s password varchar(255);
    dcl-s remember_token varchar(100);
    dcl-s created_at date(*iso) inz(*job);
    dcl-s updated_at date(*iso);

    //fill variables
    exec sql
        select jt.id, jt.firstname, jt.lastname, jt.email, jt.phone, jt.email_verified_at,
            jt.passwordt, jt.remember_token, jt.created_at, jt.updated_at
        into :id, :firstName, :lastName, :email, :phone, :email_verified_at,
             :password, :remember_token, :created_at, :updated_at
        from json_table(:jsonString,
                        '$'
                         columns(id                varchar(255) path 'lax $.id',
                                 firstname         varchar(50)  path 'lax $.name.first',
                                 lastname          varchar(50)  path 'lax $.name.last',
                                 email             varchar(255) path 'lax $.email',
                                 phone             varchar(255) path 'lax $.phone',
                                 email_verified_at date  path 'lax $.email_verified_at',
                                 passwordt         varchar(255) path 'lax $.password',
                                 remember_token    varchar(100) path 'lax $.remember_token',
                                 created_at        date  path 'lax $.created_at',
                                 updated_at        date  path 'lax $.updated_at'
                         )) as jt;
    //update user
    exec sql
      update TOOLSHOP_DEV.USERS
        set firstname = :firstname,
            lastname  = :lastname,
            email     = :email,
            phone     = :phone,
            email_verified_at = :email_verified_at,
            password = :password,
            remember_token = :remember_token,
            created_at = :created_at,
            updated_at = CURRENT_TIMESTAMP
        where id = :id;

end-proc;

dcl-proc USERSRV_DeleteUser export;
     dcl-pi USERSRV_DeleteUser;
        jsonString varchar(30000);
        response varchar(30000);
    end-pi;

    dcl-s id varchar(255);
    //get id from json
    exec sql
      select jt.id
      into :id
      from json_table(:jsonString,
            '$'
            columns(id      varchar(255) path 'lax $.id'
            )) as jt;

    //delete user with this id
    exec sql
      delete from TOOLSHOP_DEV.users where id = :id;


end-proc;


dcl-proc USERSRV_GetWithLibraryOrder export;
 dcl-pi USERSRV_GetWithLibraryOrder;
   jsonString varchar(30000);
   response varchar(30000);
 end-Pi;

 dcl-s result varchar(300);
 //do an sql statement on 1 of the libraries
 // make sure there is a table in both that can only be accessed in 1 of the libraries
 exec sql
   select name
     into :result
     from poclibtable;

  response = result;

end-Proc;


dcl-proc USERSRV_GetWithMultipleLibraries export;
   dcl-pi USERSRV_GetWithMultipleLibraries;
     jsonString varchar(30000);
     response varchar(30000);
   end-Pi;

   dcl-s result varchar(300);

   PROG1(result);

    response = result;
    return;


end-Proc;
