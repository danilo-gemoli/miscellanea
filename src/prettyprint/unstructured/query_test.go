package unstructured

import (
	"errors"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestSet(t *testing.T) {
	for _, tc := range []struct {
		name    string
		do      func(*Query) error
		obj     interface{}
		wantObj interface{}
		wantErr error
	}{
		{
			name: "Set through map and array",
			do:   func(q *Query) error { return q.Key("foo").At(0).Set("bar", "qux") },
			obj: map[string]interface{}{
				"foo": []interface{}{
					map[string]interface{}{"bar": "baz"},
				},
			},
			wantObj: map[string]interface{}{
				"foo": []interface{}{
					map[string]interface{}{"bar": "qux"},
				},
			},
		},
		{
			name: "Set an array entry",
			do:   func(u *Query) error { return u.At(0).Set("foo", "baz") },
			obj: []interface{}{
				map[string]interface{}{"foo": "bar"},
			},
			wantObj: []interface{}{
				map[string]interface{}{"foo": "baz"},
			},
		},
		{
			name:    "Not a map",
			do:      func(q *Query) error { return q.Key("foo").At(0).Set("bar", 1) },
			obj:     map[string]interface{}{"foo": []interface{}{[]interface{}{}}},
			wantErr: errors.New(`".foo[0]" is not a map`),
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			err := tc.do(NewQuery(tc.obj))

			if err != nil && tc.wantErr == nil {
				t.Fatalf("want err nil but got: %v", err)
			}
			if err == nil && tc.wantErr != nil {
				t.Fatalf("want err %v but nil", tc.wantErr)
			}
			if err != nil && tc.wantErr != nil {
				if tc.wantErr.Error() != err.Error() {
					t.Fatalf("expect error %q but got %q", tc.wantErr.Error(), err.Error())
				}
				return
			}

			if diff := cmp.Diff(tc.wantObj, tc.obj); diff != "" {
				t.Errorf("%s", diff)
			}
		})
	}
}

func TestObj(t *testing.T) {
	for _, tc := range []struct {
		name    string
		do      func(*Query) (interface{}, error)
		obj     interface{}
		wantObj interface{}
		wantErr error
	}{
		{
			name:    "Get an integer",
			do:      func(q *Query) (interface{}, error) { return q.Key("foo").At(1).Obj() },
			obj:     map[string]interface{}{"foo": []interface{}{1, 2}},
			wantObj: 2,
		},
		{
			name:    "Not a map",
			do:      func(q *Query) (interface{}, error) { return q.Key("foo").Obj() },
			obj:     "garbage",
			wantErr: errors.New(`"" is not a map`),
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			obj, err := tc.do(NewQuery(tc.obj))

			if err != nil && tc.wantErr == nil {
				t.Fatalf("want err nil but got: %v", err)
			}
			if err == nil && tc.wantErr != nil {
				t.Fatalf("want err %v but nil", tc.wantErr)
			}
			if err != nil && tc.wantErr != nil {
				if tc.wantErr.Error() != err.Error() {
					t.Fatalf("expect error %q but got %q", tc.wantErr.Error(), err.Error())
				}
				return
			}

			if diff := cmp.Diff(tc.wantObj, obj); diff != "" {
				t.Errorf("%s", diff)
			}
		})
	}
}
