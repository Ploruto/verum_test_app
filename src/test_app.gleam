import generated/models/user
import generated/queries/user_query
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import pog.{type Value}
import verum/core/database

pub fn main() -> Nil {
  io.println("=== Verum Test App ===")

  case database.start_database() {
    Ok(db) -> {
      // find all 
      case user_query.find_all(db) {
        Ok(users) -> {
          users
          |> list.each(fn(u) { echo u.email })
        }
        Error(_) -> {
          todo
        }
      }

      case
        user_query.find_by_field(db, user.Email, pog.text("user@email.com"))
      {
        Ok(users) -> {
          users |> list.each(fn(user) { echo user })
        }
        Error(_) -> {
          Nil
        }
      }
    }
    Error(_) -> {
      todo
    }
  }
}
