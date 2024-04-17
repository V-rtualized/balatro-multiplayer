// Taken from https://serde.rs/impl-serializer.html
use crate::error::{Error, Result};
use serde::ser::{self, Serialize};

pub struct Serializer {
    output: String,
}

// By convention, the public API of a Serde serializer is one or more `to_abc`
// functions such as `to_string`, `to_bytes`, or `to_writer` depending on what
// Rust types the serializer is able to produce as output.
//
// This basic serializer supports only `to_string`.
pub fn to_string<T>(value: &T) -> Result<String>
where
    T: Serialize,
{
    let mut serializer = Serializer {
        output: String::new(),
    };
    value.serialize(&mut serializer)?;
    Ok(serializer.output)
}

impl<'a> ser::Serializer for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    type SerializeSeq = Self;
    type SerializeTuple = Self;
    type SerializeTupleStruct = Self;
    type SerializeTupleVariant = Self;
    type SerializeMap = Self;
    type SerializeStruct = Self;
    type SerializeStructVariant = Self;

    fn serialize_bool(self, v: bool) -> Result<()> {
        self.output += if v { "true" } else { "false" };
        Ok(())
    }

    fn serialize_i8(self, v: i8) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i16(self, v: i16) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i32(self, v: i32) -> Result<()> {
        self.serialize_i64(i64::from(v))
    }

    fn serialize_i64(self, v: i64) -> Result<()> {
        self.output += &v.to_string();
        Ok(())
    }

    fn serialize_u8(self, v: u8) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u16(self, v: u16) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u32(self, v: u32) -> Result<()> {
        self.serialize_u64(u64::from(v))
    }

    fn serialize_u64(self, v: u64) -> Result<()> {
        self.output += &v.to_string();
        Ok(())
    }

    fn serialize_f32(self, v: f32) -> Result<()> {
        self.serialize_f64(f64::from(v))
    }

    fn serialize_f64(self, v: f64) -> Result<()> {
        self.output += &v.to_string();
        Ok(())
    }

    fn serialize_char(self, v: char) -> Result<()> {
        self.serialize_str(&v.to_string())
    }

    fn serialize_str(self, v: &str) -> Result<()> {
        self.output += v;
        Ok(())
    }

    fn serialize_bytes(self, v: &[u8]) -> Result<()> {
        use serde::ser::SerializeSeq;
        let mut seq = self.serialize_seq(Some(v.len()))?;
        for byte in v {
            seq.serialize_element(byte)?;
        }
        seq.end()
    }

    fn serialize_none(self) -> Result<()> {
        self.serialize_unit()
    }

    fn serialize_some<T>(self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(self)
    }

    // In Serde, unit means an anonymous value containing no data.
    fn serialize_unit(self) -> Result<()> {
        self.output += "null";
        Ok(())
    }

    // Unit struct means a named value containing no data.
    // There is no need to serialize the name in most formats.
    fn serialize_unit_struct(self, _name: &'static str) -> Result<()> {
        self.serialize_unit()
    }

    // When serializing a unit variant (or any other kind of variant), formats
    // can choose whether to keep track of it by index or by name. Binary
    // formats typically use the index of the variant and human-readable formats
    // typically use the name.
    fn serialize_unit_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
    ) -> Result<()> {
        self.serialize_str(variant)
    }

    // As is done here, serializers are encouraged to treat newtype structs as
    // insignificant wrappers around the data they contain.
    fn serialize_newtype_struct<T>(self, _name: &'static str, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        value.serialize(self)
    }

    // Note that newtype variant (and all of the other variant serialization
    // methods) refer exclusively to the "externally tagged" enum
    // representation.
    //
    // Serialize this to JSON in externally tagged form as `{ NAME: VALUE }`.
    fn serialize_newtype_variant<T>(
        self,
        _name: &'static str,
        _variant_index: u32,
        variant: &'static str,
        value: &T,
    ) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        variant.serialize(&mut *self)?;
        self.output += ":";
        value.serialize(&mut *self)?;
        Ok(())
    }

    fn serialize_seq(self, _len: Option<usize>) -> Result<Self::SerializeSeq> {
        Err(Error::Message("Not supported".to_string()))
    }

    fn serialize_tuple(self, _len: usize) -> Result<Self::SerializeTuple> {
        Err(Error::Message("Not supported".to_string()))
    }

    // Tuple structs look just like sequences in JSON.
    fn serialize_tuple_struct(
        self,
        _name: &'static str,
        len: usize,
    ) -> Result<Self::SerializeTupleStruct> {
        self.serialize_seq(Some(len))
    }

    // Tuple variants are represented in JSON as `{ NAME: [DATA...] }`. Again
    // this method is only responsible for the externally tagged representation.
    fn serialize_tuple_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        _variant: &'static str,
        _len: usize,
    ) -> Result<Self::SerializeTupleVariant> {
        Err(Error::Message("Not supported".to_string()))
    }

    fn serialize_map(self, _len: Option<usize>) -> Result<Self::SerializeMap> {
        Ok(self)
    }

    fn serialize_struct(self, _name: &'static str, len: usize) -> Result<Self::SerializeStruct> {
        self.serialize_map(Some(len))
    }

    // This is the externally tagged representation.
    fn serialize_struct_variant(
        self,
        _name: &'static str,
        _variant_index: u32,
        _variant: &'static str,
        _len: usize,
    ) -> Result<Self::SerializeStructVariant> {
        Err(Error::Message("Not supported".to_string()))
    }
}

// The following 7 impls deal with the serialization of compound types like
// sequences and maps. Serialization of such types is begun by a Serializer
// method and followed by zero or more calls to serialize individual elements of
// the compound type and one call to end the compound type.
//
// This impl is SerializeSeq so these methods are called after `serialize_seq`
// is called on the Serializer.
impl<'a> ser::SerializeSeq for &'a mut Serializer {
    // Must match the `Ok` type of the serializer.
    type Ok = ();
    // Must match the `Error` type of the serializer.
    type Error = Error;

    // Serialize a single element of the sequence.
    fn serialize_element<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        if !self.output.ends_with('[') {
            self.output += ",";
        }
        value.serialize(&mut **self)
    }

    // Close the sequence.
    fn end(self) -> Result<()> {
        self.output += "]";
        Ok(())
    }
}

// Same thing but for tuples.
impl<'a> ser::SerializeTuple for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_element<T>(&mut self, _value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        Err(Error::Message("Not supported".to_string()))
    }

    fn end(self) -> Result<()> {
        Err(Error::Message("Not supported".to_string()))
    }
}

// Same thing but for tuple structs.
impl<'a> ser::SerializeTupleStruct for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_field<T>(&mut self, _value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        Err(Error::Message("Not supported".to_string()))
    }

    fn end(self) -> Result<()> {
        Err(Error::Message("Not supported".to_string()))
    }
}

// Tuple variants are a little different. Refer back to the
// `serialize_tuple_variant` method above:
impl<'a> ser::SerializeTupleVariant for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_field<T>(&mut self, _value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        Err(Error::Message("Not supported".to_string()))
    }

    fn end(self) -> Result<()> {
        Err(Error::Message("Not supported".to_string()))
    }
}

// Some `Serialize` types are not able to hold a key and value in memory at the
// same time so `SerializeMap` implementations are required to support
// `serialize_key` and `serialize_value` individually.
//
// There is a third optional method on the `SerializeMap` trait. The
// `serialize_entry` method allows serializers to optimize for the case where
// key and value are both available simultaneously. In JSON it doesn't make a
// difference so the default behavior for `serialize_entry` is fine.
impl<'a> ser::SerializeMap for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_key<T>(&mut self, key: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        key.serialize(&mut **self)
    }

    // It doesn't make a difference whether the colon is printed at the end of
    // `serialize_key` or at the beginning of `serialize_value`. In this case
    // the code is a bit simpler having it here.
    fn serialize_value<T>(&mut self, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        self.output += ":";
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.output += "\n";
        Ok(())
    }
}

// Structs are like maps in which the keys are constrained to be compile-time
// constant strings.
impl<'a> ser::SerializeStruct for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_field<T>(&mut self, key: &'static str, value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        if !self.output.is_empty() {
            self.output += ",";
        }
        key.serialize(&mut **self)?;
        self.output += ":";
        value.serialize(&mut **self)
    }

    fn end(self) -> Result<()> {
        self.output += "\n";
        Ok(())
    }
}

// Similar to `SerializeTupleVariant`, here the `end` method is responsible for
// closing both of the curly braces opened by `serialize_struct_variant`.
impl<'a> ser::SerializeStructVariant for &'a mut Serializer {
    type Ok = ();
    type Error = Error;

    fn serialize_field<T>(&mut self, _key: &'static str, _value: &T) -> Result<()>
    where
        T: ?Sized + Serialize,
    {
        Err(Error::Message("Not supported".to_string()))
    }

    fn end(self) -> Result<()> {
        Err(Error::Message("Not supported".to_string()))
    }
}

////////////////////////////////////////////////////////////////////////////////

#[cfg(test)]
mod test {
    use crate::{
        actions::{Action, ActionClientToServer, ActionServerToClient},
        game_mode::GameInfo,
        lobby::GameMode,
    };

    use super::to_string;
    use serde::Serialize;

    #[test]
    fn test_struct() {
        #[derive(Serialize)]
        struct Test {
            action: String,
            int: u32,
            string: String,
        }

        let test = Test {
            action: "test".to_string(),
            int: 1,
            string: "hello".to_string(),
        };
        let expected = "action:test,int:1,string:hello\n";
        assert_eq!(to_string(&test).unwrap(), expected);
    }

    #[test]
    fn test_enum() {
        #[derive(Serialize)]
        enum E {
            Unit,
            Newtype(u32),
        }

        let u = E::Unit;
        let expected = r#"Unit"#;
        assert_eq!(to_string(&u).unwrap(), expected);

        let n = E::Newtype(1);
        let expected = r#"Newtype:1"#;
        assert_eq!(to_string(&n).unwrap(), expected);
    }

    #[test]
    fn test_connected() {
        let connected = Action::ServerToClient(ActionServerToClient::Connected);
        let expected = "action:connected\n";
        assert_eq!(to_string(&connected).unwrap(), expected);
    }

    #[test]
    fn test_create_lobby() {
        let create_lobby = Action::ClientToServer(ActionClientToServer::CreateLobby {
            game_mode: GameMode::Attrition.to_string(),
        });
        let expected = "action:createLobby,gameMode:attrition\n";
        assert_eq!(to_string(&create_lobby).unwrap(), expected);
    }

    #[test]
    fn test_play_hand() {
        let play_hand = Action::ClientToServer(ActionClientToServer::PlayHand {
            score: 1,
            hands_left: 2,
        });
        let expected = "action:playHand,score:1,handsLeft:2\n";
        assert_eq!(to_string(&play_hand).unwrap(), expected);
    }

    #[test]
    fn test_lobby_info() {
        let lobby_info = Action::ServerToClient(ActionServerToClient::LobbyInfo {
            host: "test".to_string(),
            guest: None,
            is_host: true,
        });
        let expected = "action:lobbyInfo,host:test,isHost:true\n";
        assert_eq!(to_string(&lobby_info).unwrap(), expected);
    }

    #[test]
    fn test_game_info() {
        let game_info = Action::ServerToClient(ActionServerToClient::GameInfo(GameInfo {
            small: None,
            big: Some("bigBlind".to_string()),
            boss: None,
        }));
        let expected = "action:gameInfo,big:bigBlind\n";
        assert_eq!(to_string(&game_info).unwrap(), expected);
    }

    #[test]
    fn test_start_game() {
        let start_game = Action::ServerToClient(ActionServerToClient::StartGame {
            deck: "deck".to_string(),
            stake: Some(1),
            seed: None,
        });
        let expected = "action:startGame,deck:deck,stake:1\n";
        assert_eq!(to_string(&start_game).unwrap(), expected);
    }
}
