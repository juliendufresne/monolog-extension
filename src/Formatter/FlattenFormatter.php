<?php

declare(strict_types=1);

namespace JulienDufresne\MonologExtension\Formatter;

use Monolog\Formatter\FormatterInterface;

final class FlattenFormatter implements FormatterInterface
{
    /** @var FormatterInterface */
    private $decoratedFormatter;
    /** @var bool */
    private $flattenContext;
    /** @var bool */
    private $flattenExtra;

    /**
     * @param FormatterInterface $decoratedFormatter
     * @param bool               $flattenContext
     * @param bool               $flattenExtra
     */
    public function __construct(FormatterInterface $decoratedFormatter, bool $flattenContext = true, bool $flattenExtra = true)
    {
        $this->decoratedFormatter = $decoratedFormatter;
        $this->flattenContext = $flattenContext;
        $this->flattenExtra = $flattenExtra;
    }

    /**
     * Formats a log record.
     *
     * @param  array $record A record to format
     *
     * @return mixed The formatted record
     */
    public function format(array $record)
    {
        if ($this->flattenContext && !empty($record['context'])) {
            $this->flatten($record, $record['context'], 'context');
            unset ($record['context']);
        }

        if ($this->flattenExtra && !empty($record['extra'])) {
            $this->flatten($record, $record['extra'], 'extra');
            unset ($record['extra']);
        }

        return $this->decoratedFormatter->format($record);
    }

    /**
     * Formats a set of log records.
     *
     * @param  array $records A set of records to format
     *
     * @return mixed The formatted set of records
     */
    public function formatBatch(array $records)
    {
        foreach ($records as $key => $record) {
            $records[$key] = $this->format($record);
        }

        return $records;
    }

    private function flatten(array &$record, $data, string $prefix)
    {
        if (null === $data) {
            return;
        }

        if (!\is_array($data)) {
            $record[$prefix] = $data;

            return;
        }

        foreach ($data as $key => $datum) {
            $this->flatten($record, $datum, $prefix.'.'.$key);
        }
    }
}
