<?php

declare(strict_types=1);

namespace JulienDufresne\MonologExtension\Tests\Formatter;

use Monolog\Formatter\FormatterInterface;
use PHPUnit\Framework\TestCase;
use JulienDufresne\MonologExtension\Formatter\FlattenFormatter;

final class FlattenFormatterTest extends TestCase
{

    /**
     * @dataProvider provideFormatData
     *
     * @param bool  $flattenContext
     * @param bool  $flattenExtra
     * @param array $record
     * @param array $expectedResult
     *
     * @throws \ReflectionException
     */
    public function testFormat(bool $flattenContext, bool $flattenExtra, array $record, array $expectedResult)
    {
        $formatter = $this->createMock(FormatterInterface::class);
        $formatter->expects(self::any())
            ->method('format')
            ->willReturnArgument(0);

        $object = new FlattenFormatter($formatter, $flattenContext, $flattenExtra);

        $result = $object->format($record);

        $this->assertSame($expectedResult, $result);
    }

    public function provideFormatData()
    {
        $record = [
            'message' => 'my message',
            'extra' => [
                'key' => 'value',
                'foo' => [
                    'bar' => 'baz'
                ]
            ],
            'context' => [
                'key' => 'value',
                'foo' => [
                    'bar' => 'baz'
                ]
            ]
        ];

        return [
            'do not flatten anything' => [
                'flattenContext' => false,
                'flattenExtra' => false,
                'record' => $record,
                'expectedResult' => $record,
            ],
            'flatten context' => [
                'flattenContext' => true,
                'flattenExtra' => false,
                'record' => $record,
                'expectedResult' => [
                    'message' => 'my message',
                    'extra' => [
                        'key' => 'value',
                        'foo' => [
                            'bar' => 'baz'
                        ]
                    ],
                    'context.key' => 'value',
                    'context.foo.bar' => 'baz'
                ],
            ],
            'flatten extra' => [
                'flattenContext' => false,
                'flattenExtra' => true,
                'record' => $record,
                'expectedResult' => [
                    'message' => 'my message',
                    'context' => [
                        'key' => 'value',
                        'foo' => [
                            'bar' => 'baz'
                        ]
                    ],
                    'extra.key' => 'value',
                    'extra.foo.bar' => 'baz',
                ],
            ],
            'flatten both' => [
                'flattenContext' => true,
                'flattenExtra' => true,
                'record' => $record,
                'expectedResult' => [
                    'message' => 'my message',
                    'context.key' => 'value',
                    'context.foo.bar' => 'baz',
                    'extra.key' => 'value',
                    'extra.foo.bar' => 'baz',
                ],
            ],
        ];
    }
}
