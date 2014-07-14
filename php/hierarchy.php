<?php defined('SYSPATH') or die('No direct script access.');
/**
 * MySQL "Closure Table" for Kohana based on Bill Karwin design.
 * 
 * @link  http://www.slideshare.net/billkarwin/models-for-hierarchical-data 
 * @TODO  improve
 * 
 * sql schema:
 * CREATE TABLE `closures` (
 *   `id` int(11) NOT NULL AUTO_INCREMENT,
 *   `ancestor` int(11) NOT NULL,
 *   `descendant` int(11) NOT NULL,
 *   `lvl` int(11) NOT NULL,
 *   PRIMARY KEY (`id`)
 * );
 * 
 */
class Hierarchy {

	// reference table
	public $table;

	public $closure_table = 'closures';

	public function __construct($table_name, $closure_table = NULL)
	{
		$this->table = $table_name;

		if ($closure_table !== NULL)
			$this->closure_table = $closure_table;
	}

	/**
	 * Add a node (as last child).
	 * 
	 * @param  int    node id
	 * @param  int    target id
	 * @return boolean
	 */
	public function add($node_id, $target_id = 0)
	{
		$query = DB::select(DB::expr('ancestor, '.$node_id.', lvl+1'))
			->from($this->closure_table)
			->where('descendant', '=', $target_id);

		$query1 = DB::select(DB::expr($node_id.','.$node_id.',0'))
			->union($query);

		$query2 = 'INSERT INTO '.$this->closure_table.' (ancestor, descendant,lvl) '.$query1;

		$result = DB::query(Database::INSERT, $query2)->execute();

		return ($result AND count($result)>0);
	}

	/**
	 * Check if current node has children.
	 * 
	 * @param   int       node id
	 * @return  boolean
	 */
	public function has_children($node_id)
	{
		$descendants = DB::select('descendant')
			->from($this->closure_table)
			->where('ancestor','=', $node_id);

		return (bool)  DB::select(array('COUNT("*")', 'total'))
			->from($this->closure_table)
			->where('ancestor', 'IN', DB::expr('('.$descendants.')'))
			->where('descendant', '<>', $node_id)
			->execute()
			->get('total');
	}

	/**
	 * Get parent(s) of current node.
	 * 
	 * @param  int  current node id
	 * @param  boolean  include current node on result
	 * @param  int  level up (e.g direct parent = 1)
	 * @param  array  column/field name(s)
	 * @return mixed  array if succeed
	 */
	public function get_parent(
		$node_id,
		$self = FALSE,
		$level = NULL,
		array $column = NULL
	){
		if ($column !== NULL)
		{
			if ( ! in_array('id', $column))
				array_unshift($column, 'id');

			$column = 't.'.implode(',t.', $column);
		}
		else
		{
			$column = 't.*';
		}

		$query = DB::select($column, array('c.lvl', 'level'))
			->from(array($this->table, 't'))
			->join(array($this->closure_table, 'c'))
				->on('t.id', '=', 'c.ancestor')
			->where('c.descendant', '=', $node_id)
			->where('t.safe_url', 'IS NOT', NULL);

		if ( ! $self)
			$query->where('c.ancestor', '<>', $node_id);

		if ($level)
			$query->where('c.lvl' ,'=', $level);

		$query = $query->order_by('t.id')->execute();

		if ($query->count())
		{
			$query = $query->as_array();

			if ($level)
			{
				return $query[0];
			}

			return $query;
		}

		return FALSE;
	}

	/**
	 * Fetch children(s).
	 * 
	 * Example to generate nested tree:
	 * 
	 *   $h = new Hierarchy('refrence_table');
	 *   $data = $h->get_children(1, TRUE, FALSE, NULL, TRUE);
	 *   print_r($data);
	 * 
	 * If level/depth specified then self will be ignore.
	 * 
	 * @param  int  node id
	 * @param  boolean  include current node on result
	 * @param  int  node level/depth (e.g direct children = 1) 
	 * @param  array  column/field name(s)
	 * @param  boolean  nestify the result
	 * @return mixed
	 */
	public function get_children(
		$node_id = 1,
		$self = FALSE,
		$level = FALSE,
		array $column = NULL,
		$nested = FALSE
	){
		if ($column !== NULL)
		{
			if ( ! in_array('id', $column))
				array_unshift($column, 'id');

			$column = 't.'.implode(',t.', $column);
		}
		else
		{
			$column = 't.*';
		}

		$query = DB::select(
				$column,
				array('c2.ancestor', 'parent'),
				array('c1.lvl', 'level')
			)
			->from(array($this->closure_table, 'c1'))
			->join(array($this->table, 't'))
				->on('t.id', '=','c1.descendant')
			->join(array($this->closure_table, 'c2'), 'LEFT')
				->on(
					'c2.lvl',
					'=',
					DB::expr('1 AND c2.descendant = c1.descendant ')
				)
			->where('c1.ancestor', '=', $node_id);

		if ( ! $self)
			$query->where('c1.descendant', '<>', $node_id);

		if ($level)
			$query->where('c1.lvl','=', $level);

		$query = $query->execute();

		if ( ! $query->count())
			return FALSE;

		$result = $query->as_array();

		if ($nested AND ! $level)
		{
			$refs = array();

			foreach ($result as $node)
			{
				$current = &$refs[$node['id']];

				$current['data'] = $node;

				if ($node['parent'])
					$refs[$node['parent']]['children'][$node['id']] = &$current;
			}

			$result = $refs[$node_id];
		}

		return $result;
	}

	/**
	 * TODO: optional recursion
	 * 
	 * Delete node.
	 * 
	 * @param  int      node id
	 * @param  boolean  delete data from reference table
	 * @return mixed
	 */
	public function delete($node_id, $delete_reference = TRUE)
	{
		$operand = DB::select('descendant')
			->from($this->closure_table)
			->where('ancestor', '=', $node_id);

		$query = DB::select('id','descendant')
			->from($this->closure_table)
			->where('descendant','IN', DB::expr('('.$operand.')'))
			->execute();

		if ($query->count())
		{
			$descendants = Arr::pluck($query, 'id');

			$result = DB::delete($this->closure_table)
				->where(
					'id',
					'IN',
					DB::expr('('.implode(',',$descendants).')')
				)
				->execute();

			if ($delete_reference)
			{
				$descendants = Arr::pluck($query, 'descendant');

				$result = DB::delete($this->table)
					->where(
						'id',
						'IN',
						DB::expr('('.implode(',',$descendants).')')
					)
					->execute();
			}

			return $result;
		}

		return FALSE;
	}

	/**
	 * Move node with its children to another node.
	 * 
	 * @link  http://www.mysqlperformanceblog.com/2011/02/14/moving-subtrees-in-closure-table/
	 * 
	 * @param  int  node to be moved
	 * @param  int  target node
	 * @return void
	 */
	public function move($node_id, $target_id)
	{
		// MySQL’s multi-table DELETE
		$query1 = 'DELETE a FROM '.$this->closure_table.' AS a ';
		$query1 .= 'JOIN '.$this->closure_table.' AS d ON a.descendant = d.descendant ';
		$query1 .= 'LEFT JOIN '.$this->closure_table.' AS x ';
		$query1 .= 'ON x.ancestor = d.ancestor AND x.descendant = a.ancestor ';
		$query1 .= 'WHERE d.ancestor = '.$node_id.'  AND x.ancestor IS NULL';

		DB::query(Database::DELETE, $query1)->execute();

		$query2 = 'INSERT INTO '.$this->closure_table.' (ancestor, descendant, lvl) ';
		$query2 .= 'SELECT a.ancestor, b.descendant, a.lvl+b.lvl+1 ';
		$query2 .= 'FROM '.$this->closure_table.' AS a JOIN '.$this->closure_table.' AS b ';
		$query2 .= 'WHERE b.ancestor = '.$node_id.' AND a.descendant = '.$target_id;

		DB::query(Database::INSERT, $query2)->execute();
	}

	/**
	 * Get (all) root nodes.
	 *
	 * @param  array  column/field name(s)
	 * @return  mixed
	 */
	public function get_root(array $column = NULL)
	{
		if ($column !== NULL)
		{
			$column = 't.'.implode(',t.', $column);
		}
		else
		{
			$column = 't.*';
		}

		$query = DB::select($column)
			->from(array($this->closure_table, 'c'))
			->join(array($this->table, 't'))
				->on('t.id', '=', 'c.ancestor')
			->join(array($this->closure_table, 'anc'), 'LEFT OUTER')
				->on('anc.descendant', '=', DB::expr(
					'c.descendant AND anc.ancestor <> c.ancestor'
				))
			->where('anc.ancestor', 'IS', NULL)
			->execute();

		return $query->count() ? $query->as_array() : FALSE;
	}

}
