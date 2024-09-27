package unstructured

import (
	"fmt"
)

// Query deals with yaml/json text unmarshaled into map[string]interface{}
// or []interface{} instead of typed objects.
//
// It allows querying and setting values in a convenient but type unsafe way.
// A query is one shot, this object can be reused to do multiple, different queries as
// it overwrites the starting object with comes out by the intermediate queries.
//
// foo:
//   - bar: baz
//
// The previous yaml might be unmarshaled into:
//
// unmarshaled := map[string][]interface{"foo": []interface{map[string]interface{}{"bar": "baz"}}}
//
// and then modified through the following query:
//
// q := NewQuerier{obj: unmarshaled}
// err := q.Key("foo").At(0).Set("bar", "qux")
//
// the result is:
//
// foo:
//   - bar: qux
type Query struct {
	obj interface{}
	// err is the current error that might arise while querying the object.
	// We will keep querying as long as this is nil, doing nothing otherwise.
	// This variable is for convenience only, as it allows chaining methods instead
	// of invoking a method, checking for any error and eventually go ahead with
	// the next one.
	err error
	// jq-like query: '.foo.bar[0].baz'. It gets constructed incrementally.
	q string
}

// Treat the current object as an array, get i-th entry and store it as current object
func (u *Query) At(i int) *Query {
	if u.err != nil {
		return u
	}
	array, ok := u.obj.([]interface{})
	if !ok {
		u.err = fmt.Errorf("%q is not an array", u.q)
		return u
	}
	if i >= len(array) {
		u.err = fmt.Errorf("%q[%d/%d] index out of bound", u.q, i, len(array))
		return u
	}
	u.obj = array[i]
	u.q += fmt.Sprintf("[%d]", i)
	return u
}

// Treat the current object as map, get the value at `key` and store it as current object
func (u *Query) Key(key string) *Query {
	if u.err != nil {
		return u
	}
	current, ok := u.obj.(map[string]interface{})
	if !ok {
		u.err = fmt.Errorf("%q is not a map", u.q)
		return u
	}
	next, ok := current[key]
	if !ok {
		u.err = fmt.Errorf("key %s not found", key)
		return u
	}
	u.obj = next
	u.q += "." + key
	return u
}

// Treat the current object as map, set `key` to `value`
func (u *Query) Set(key string, value interface{}) error {
	if u.err != nil {
		return u.err
	}
	m, ok := u.obj.(map[string]interface{})
	if !ok {
		return fmt.Errorf("%q is not a map", u.q)
	}
	m[key] = value
	return nil
}

// Get the object out of the current query
func (u *Query) Obj() (interface{}, error) {
	if u.err != nil {
		return nil, u.err
	}
	return u.obj, nil
}

func NewQuery(obj interface{}) *Query {
	return &Query{obj: obj}
}
