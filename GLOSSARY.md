# Pickle

Pickle helps people choose between discrete options by keeping Lists of Items and picking among them.

## Language

### Lists and Items

**List**:
A user-created set of Items to pick from.
_Avoid_: Collection

**List type**:
The kind of List (Movie, TV or Custom), which determines the Properties every List of that kind has.
_Avoid_: Category, collection type

**Item**:
One thing in a List that can be picked.
_Avoid_: Option, entry, collection entry

### Properties

**Property**:
A named attribute that a List's Items can carry, such as Genre or Runtime, defined either by the List type or on the List itself.
_Avoid_: Field, attribute, custom field

**Value**:
What one Item holds for one Property.
_Avoid_: Field value, property value

### Adding Items

**Item editor**:
The full-screen view for creating or editing a single Item and its Values.
_Avoid_: Add dialog, popup

**Quick add**:
The ghost Item at the end of a List where you type a name to add an Item, after which the next ghost Item is ready for typing.
_Avoid_: Ghost entry, inline add
