
# MongoDB Docker Compose Setup Instructions

This README provides the steps to create a new MongoDB database and user through the MongoDB console within a Docker container.

## Prerequisites

Make sure Docker and Docker Compose are installed and running on your machine.

## Steps to Create a Database and User in MongoDB

1. **Access the MongoDB Console**

   First, open a terminal and connect to the MongoDB shell in the running container:

   ```bash
   docker exec -it mongo-docker mongo -u admin -p mayonesa --authenticationDatabase admin
   ```

   This command connects you to the MongoDB shell as the `admin` user with the password `mayonesa`.

2. **Create a Database**

   Switch to the database you want to create. MongoDB will automatically create it when data is inserted.

   ```javascript
   use nombre_de_tu_base_de_datos
   ```

   Replace `nombre_de_tu_base_de_datos` with your desired database name.

3. **Create a User for the Database**

   With the desired database selected, create a new user with the following command:

   ```javascript
   db.createUser({
      user: "nuevo_usuario",
      pwd: "nueva_contraseña",
      roles: [{ role: "readWrite", db: "nombre_de_tu_base_de_datos" }]
   })
   ```

   Replace the placeholders:
   - `nuevo_usuario` with the username you want to create.
   - `nueva_contraseña` with the password for this user.
   - `nombre_de_tu_base_de_datos` with the name of the database.

   This will create the database (if it does not exist) and assign the `readWrite` role to the user.

## Example

To create a database called `test_db` with a user `test_user` and password `test_password`, execute:

```javascript
use test_db
db.createUser({
   user: "test_user",
   pwd: "test_password",
   roles: [{ role: "readWrite", db: "test_db" }]
})
```

Now, `test_user` can connect to the `test_db` database with read and write permissions.

