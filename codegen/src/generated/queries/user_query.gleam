import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/int
import gleam/list
import gleam/result
import gleam/string
import generated/models/user.{type User, type UserField, User, Id, Name, Email, Description, OrderNumber, CreatedAt, UpdatedAt, Age}
import pog.{type Connection, type QueryError, type Returned, type Value}

/// Timestamp decoder - decode integers to strings for now  
const decode_timestamp = decode.int

/// Decoder for converting database rows to User type
/// Expects columns in order: id, name, email, description, order_number, created_at, updated_at, age
fn user_decoder() {
  {
    use id <- decode.field(0, decode.int)
  use name <- decode.field(1, decode.string)
  use email <- decode.field(2, decode.string)
  use description <- decode.field(3, decode.optional(decode.string))
  use order_number <- decode.field(4, decode.int)
  use created_at <- decode.field(5, decode_timestamp)
  use updated_at <- decode.field(6, decode_timestamp)
  use age <- decode.field(7, decode.int)
    decode.success(User(id:, name:, email:, description:, order_number:, created_at:, updated_at:, age:))
  }
}

/// Convert UserField to database column name
pub fn field_to_column_name(field: UserField) -> String {
  case field {
    Id -> "id"
    Name -> "name"
    Email -> "email"
    Description -> "description"
    OrderNumber -> "order_number"
    CreatedAt -> "created_at"
    UpdatedAt -> "updated_at"
    Age -> "age"
  }
}

/// Find all user records
pub fn find_all(conn: Connection) -> Result(List(User), QueryError) {
  let query = 
    pog.query("SELECT id, name, email, description, order_number, created_at, updated_at, age FROM users")
    |> pog.returning(user_decoder())
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Find user records by a specific field
pub fn find_by_field(
  conn: Connection,
  field: UserField,
  value: Value,
) -> Result(List(User), QueryError) {
  let field_name = field_to_column_name(field)
  let sql = "SELECT id, name, email, description, order_number, created_at, updated_at, age FROM users WHERE " <> field_name <> " = $1"
  
  let query = 
    pog.query(sql)
    |> pog.returning(user_decoder())
    |> pog.parameter(value)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Find a user by ID
pub fn find_by_id(conn: Connection, id: Value) -> Result(List(User), QueryError) {
  let query = 
    pog.query("SELECT id, name, email, description, order_number, created_at, updated_at, age FROM users WHERE id = $1")
    |> pog.returning(user_decoder())
    |> pog.parameter(id)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.rows)
    Error(error) -> Error(error)
  }
}

/// Create a new user record
pub fn create(
  conn: Connection,
  name: Value,
  email: Value,
  description: Value,
  age: Value,
) -> Result(User, QueryError) {
  let sql = "INSERT INTO users (name, email, description, age) VALUES ($1, $2, $3, $4) RETURNING id, name, email, description, order_number, created_at, updated_at, age"
  
  let query = 
    pog.query(sql)
    |> pog.returning(user_decoder())
    |> pog.parameter(name)
    |> pog.parameter(email)
    |> pog.parameter(description)
    |> pog.parameter(age)
  
  case pog.execute(query, conn) {
    Ok(result) -> {
      case result.rows {
        [user] -> Ok(user)
        _ -> Error(pog.ConstraintViolated("Expected exactly one User", "", ""))
      }
    }
    Error(error) -> Error(error)
  }
}

/// Update a user record by ID
pub fn update(
  conn: Connection,
  id: Value,
  name: Value,
  email: Value,
  description: Value,
  order_number: Value,
  age: Value,
) -> Result(User, QueryError) {
  let sql = "UPDATE users SET name = $2, email = $3, description = $4, order_number = $5, age = $6 WHERE id = $1 RETURNING id, name, email, description, order_number, created_at, updated_at, age"
  
  let query = 
    pog.query(sql)
    |> pog.returning(user_decoder())
    |> pog.parameter(id)
    |> pog.parameter(name)
    |> pog.parameter(email)
    |> pog.parameter(description)
    |> pog.parameter(order_number)
    |> pog.parameter(age)
  
  case pog.execute(query, conn) {
    Ok(result) -> {
      case result.rows {
        [user] -> Ok(user)
        _ -> Error(pog.ConstraintViolated("Expected exactly one User", "", ""))
      }
    }
    Error(error) -> Error(error)
  }
}

/// Update user record with dynamic field updates
pub fn update_partial(
  conn: Connection,
  id: Value,
  updates: List(#(String, Value)),
) -> Result(User, QueryError) {
  case updates {
    [] -> Error(pog.ConstraintViolated("No fields to update", "", ""))
    _ -> {
      let set_clauses =
        updates
        |> list.index_map(fn(update, i) {
          let #(field_name, _) = update
          field_name <> " = $" <> int.to_string(i + 2)
        })
        |> string.join(", ")
      
      let sql = "UPDATE users SET " <> set_clauses <> " WHERE id = $1 RETURNING id, name, email, description, order_number, created_at, updated_at, age"
      
      let query =
        pog.query(sql)
        |> pog.returning(user_decoder())
        |> pog.parameter(id)
      
      let final_query =
        updates
        |> list.fold(query, fn(q, update) {
          let #(_, value) = update
          pog.parameter(q, value)
        })
      
      case pog.execute(final_query, conn) {
        Ok(result) -> {
          case result.rows {
            [record] -> Ok(record)
            [] -> Error(pog.ConstraintViolated("User not found", "", ""))
            _ -> Error(pog.ConstraintViolated("Multiple users updated", "", ""))
          }
        }
        Error(error) -> Error(error)
      }
    }
  }
}

/// Delete a user record by ID
pub fn delete(conn: Connection, id: Value) -> Result(Int, QueryError) {
  let query = 
    pog.query("DELETE FROM users WHERE id = $1")
    |> pog.returning(decode.dynamic)
    |> pog.parameter(id)
  
  case pog.execute(query, conn) {
    Ok(result) -> Ok(result.count)
    Error(error) -> Error(error)
  }
}