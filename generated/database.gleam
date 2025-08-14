import gleam/erlang/process
import gleam/io
import gleam/option
import pog

pub fn start_database() {
  let pool_name = process.new_name("db_pool")

  let config =
    pog.default_config(pool_name)
    |> pog.host("localhost")
    |> pog.port(5432)
    |> pog.database("genau_db")
    |> pog.user("postgres")
    |> pog.password(option.None)

  case pog.start(config) {
    Ok(started) -> {
      Ok(started.data)
    }
    Error(error) -> {
      io.println_error("Failed to connect to database")
      Error(error)
    }
  }
}

pub fn run_query(db, sql) {
  let query = pog.query(sql)

  case pog.execute(query, db) {
    Ok(result) -> {
      Ok(result)
    }
    Error(error) -> {
      io.println_error("Query failed")
      Error(error)
    }
  }
}