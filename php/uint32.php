<?php
/**
 * Javascript-like typed array
 * 
 */
class IntArray extends SplFixedArray {

	public static function fromArray(array $array, $save_indexes = true) {
		$len = count($array);
		$name = get_called_class();
		$class = new $name($len);
		for ($i = $len; $i--;) $class[$i] = $array[$i];
		return $class;
	}
}

// range -128 to 127
class Int8Array extends IntArray {

	public function offsetSet($index , $newval) {
		$value = unpack('c*', pack('c*', $newval));
		parent::offsetSet($index, $value[1]);
	}
}

// range 0 to 255
class Uint8Array extends IntArray {

	public function offsetSet($index , $newval) {
		parent::offsetSet($index, $newval & 255);
	}
}

// range -32768 to 32767
class Int16Array extends IntArray {

	public function offsetSet($index , $newval) {
		$value = unpack('s*', pack('s*', $newval));
		parent::offsetSet($index, $value[1]);
	}
}

// range 0 to 65535
class Uint16Array extends IntArray {

	public function offsetSet($index , $newval) {
		parent::offsetSet($index, $newval & 65535);
	}
}

// range -2147483648 to 2147483647
class Int32Array extends IntArray {

	private function _intval($value) {
		if (($value < -2147483648) || ($value > 2147483647))
			return ($value & 2147483647);
		return $value;
	}

	public function offsetSet($index , $newval) {
		parent::offsetSet($index, $this->_intval($newval));
	}
}

// range 0 to 4294967295
class Uint32Array extends IntArray {

	public function offsetSet($index , $newval) {
		parent::offsetSet($index, $newval & 4294967295);
	}
}
