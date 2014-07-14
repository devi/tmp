<?php

class Pagination {

	public static function factory($total, $limit = 5, $page = 1, $adjacents = 2)
	{
		return new Pagination($total, $limit, $page, $adjacents);
	}

	public $total;

	public $limit;

	public $page;

	public $adjacents;

	public function __construct($total, $limit, $page, $adjacents)
	{
		$this->total = (int) $total;
		$this->limit = (int) $limit;
		$this->page = (int) $page;
		$this->adjacents = (int) $adjacents;

		if ($this->page < 1)
		{
			$this->page = 1;
		}
	}

	public function render()
	{
		$last = ceil($this->total / $this->limit);

		if ($last < 2 or $this->page > $last)
		{
			return FALSE;
		}

		$arr = array(
			'current' => $this->page,
			'limit' => $this->limit,
			'total' => $this->total,
			'pages' => $last
		);

		if ($this->page > 1)
		{
			$arr['previous'] = $this->page - 1;
		}

		if ($this->page < $last)
		{
			$arr['next'] = $this->page + 1;
		}

		$r1 = ($this->page - 1) * $this->limit + 1;

		$r2 = $r1 + $this->limit - 1;

		$r2 = ($this->total < $r2) ? $this->total : $r2;

		$arr['displaying'] = array(
			'items' => $r2 - $r1 + 1,
			'from' => $r1,
			'to' => $r2
		);

		if ($last < 5 + ($this->adjacents * 2))
		{
			for ($counter = 1; $counter <= $last; $counter++)
			{
				$arr['links'][] = $this->_numbers($counter);
			}
		}
		elseif ($last >= 5 + ($this->adjacents * 2))
		{
			if ($this->page < 1 + ($this->adjacents * 2))
			{
				$arr['last'] = TRUE;

				for ($counter = 1; $counter < 2 + ($this->adjacents * 2); $counter++)
				{
					$arr['links'][] = $this->_numbers($counter);
				}
			}
			elseif ($last - ($this->adjacents * 2) >= $this->page AND $this->page > ($this->adjacents * 2))
			{
				$arr['first'] = TRUE;
				$arr['last'] = TRUE;

				for ($counter = $this->page - $this->adjacents; $counter <= $this->page + $this->adjacents; $counter++)
				{
					$arr['links'][] = $this->_numbers($counter);
				}
			}
			else
			{
				$arr['first'] = TRUE;

				for ($counter = $last - ($this->adjacents * 2); $counter <= $last; $counter++)
				{
					$arr['links'][] = $this->_numbers($counter);
				}
			}
		}

		return $arr;
	}

	protected function _numbers($num)
	{
		if ($num == $this->page)
		{
			return array('active' => TRUE, 'number' => $num);
		}
		else
		{
			return array('number' => $num);
		}
	}

} // End Pagination
