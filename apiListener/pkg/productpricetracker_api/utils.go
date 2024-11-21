package productpricetracker_api

import (
	"fmt"
)

func toFloat64(v interface{}) (float64, error) {
    switch i := v.(type) {
    case float64:
        return i, nil
    case float32:
        return float64(i), nil
    case int64:
        return float64(i), nil
    case int32:
        return float64(i), nil
    case int:
        return float64(i), nil
    default:
        return 0, fmt.Errorf("unable to convert %v to float64", v)
    }
}

func toUint64(v interface{}) (uint64, error) {
	switch i := v.(type) {
	case uint64:
		return i, nil
	case uint32:
		return uint64(i), nil
	case int64:
		return uint64(i), nil
	case int32:
		return uint64(i), nil
	case int:
		return uint64(i), nil
	default:
		fmt.Println(v)
		return 0, fmt.Errorf("unable to convert %v to uint64", v)
	}
}