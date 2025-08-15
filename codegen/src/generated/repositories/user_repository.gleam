import generated/models/user.{type InsertUser, type PartialUser, type User}
import generated/queries/user_query
import generated/serializers/user_serializer
import gleam/list
import gleam/result
import pog.{type Connection, type QueryError}

/// Create a new user using Insert DTO
pub fn create_user(
  conn: Connection,
  insert_user: InsertUser,
) -> Result(User, QueryError) {
  let params = user_serializer.insert_user_to_create_params(insert_user)
  case params {
    [name_param, email_param, description_param, age_param] ->
      user_query.create(
        conn,
        name_param,
        email_param,
        description_param,
        age_param,
      )
    _ -> Error(pog.ConstraintViolated("Invalid parameters for User", "", ""))
  }
}

/// Update user using partial data
pub fn update_user_partial(
  conn: Connection,
  id: Int,
  partial: PartialUser,
) -> Result(User, QueryError) {
  let updates = user_serializer.partial_user_to_update_params(partial)
  case updates {
    [] ->
      // No updates, just return existing record
      user_query.find_by_id(conn, pog.int(id))
      |> result.try(fn(results) {
        case results {
          [record] -> Ok(record)
          [] -> Error(pog.ConstraintViolated("User not found", "", ""))
          _ -> Error(pog.ConstraintViolated("Multiple users found", "", ""))
        }
      })
    _ -> user_query.update_partial(conn, pog.int(id), updates)
  }
}

/// Find user by primary key, returning single result or error
pub fn find_user_by_id(conn: Connection, id: Int) -> Result(User, QueryError) {
  user_query.find_by_id(conn, pog.int(id))
  |> result.try(fn(results) {
    case results {
      [record] -> Ok(record)
      [] -> Error(pog.ConstraintViolated("User not found", "", ""))
      _ ->
        Error(pog.ConstraintViolated(
          "Multiple users found with same id",
          "",
          "",
        ))
    }
  })
}

// Re-export common query operations for convenience
pub fn find_all_users(conn: Connection) -> Result(List(User), QueryError) {
  user_query.find_all(conn)
}

pub fn delete_user(conn: Connection, id: Int) -> Result(Int, QueryError) {
  user_query.delete(conn, pog.int(id))
}
