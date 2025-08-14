import generated/models/user.{type User, type PartialUser}
import pog.{type Value}
import gleam/option.{None, Some}
import gleam/list

/// Convert User to create parameters
pub fn user_to_create_params(user: User) -> List(Value) {
  [
    pog.int(user.id),
    pog.text(user.name),
    pog.text(user.email),
    case user.bio {
      Some(val) -> pog.text(val)
      None -> pog.null()
    }
  ]
}

/// Convert PartialUser to update parameters
pub fn partial_user_to_update_params(partial: PartialUser) -> List(#(String, Value)) {
  []
  |> add_if_present("name", partial.name, pog.text)
  |> add_if_present("email", partial.email, pog.text)
  |> add_if_present_optional("bio", partial.bio, pog.text, pog.null())
}

/// Add field to update list if value is present
fn add_if_present(
  acc: List(#(String, Value)),
  field: String,
  value: option.Option(a),
  converter: fn(a) -> Value,
) -> List(#(String, Value)) {
  case value {
    Some(v) -> [#(field, converter(v)), ..acc]
    None -> acc
  }
}

/// Add optional field to update list if value is present (handles triple Option for nulls)
fn add_if_present_optional(
  acc: List(#(String, Value)),
  field: String,
  value: option.Option(option.Option(a)),
  converter: fn(a) -> Value,
  null_value: Value,
) -> List(#(String, Value)) {
  case value {
    Some(Some(v)) -> [#(field, converter(v)), ..acc]
    Some(None) -> [#(field, null_value), ..acc]
    None -> acc
  }
}