<?php

declare(strict_types=1);

namespace OpenAI\Responses\VectorStores\Files;

use OpenAI\Contracts\ResponseContract;
use OpenAI\Contracts\ResponseHasMetaInformationContract;
use OpenAI\Responses\Concerns\ArrayAccessible;
use OpenAI\Responses\Concerns\HasMetaInformation;
use OpenAI\Responses\Meta\MetaInformation;
use OpenAI\Testing\Responses\Concerns\Fakeable;

/**
 * @implements ResponseContract<array{object: string, data: array<int, array{id: string, object: string, usage_bytes: int, created_at: int, vector_store_id: string, status: string, last_error: ?array{code: string, message: string}}>, first_id: ?string, last_id: ?string, has_more: bool}>
 */
final class VectorStoreFileListResponse implements ResponseContract, ResponseHasMetaInformationContract
{
    /**
     * @use ArrayAccessible<array{object: string, data: array<int, array{id: string, object: string, usage_bytes: int, created_at: int, vector_store_id: string, status: string, last_error: ?array{code: string, message: string}}>, first_id: ?string, last_id: ?string, has_more: bool}>
     */
    use ArrayAccessible;

    use Fakeable;
    use HasMetaInformation;

    /**
     * @param  array<int, VectorStoreFileResponse>  $data
     */
    private function __construct(
        public readonly string $object,
        public readonly array $data,
        public readonly ?string $firstId,
        public readonly ?string $lastId,
        public readonly bool $hasMore,
        private readonly MetaInformation $meta,
    ) {}

    /**
     * Acts as static factory, and returns a new Response instance.
     *
     * @param  array{object: string, data: array<int, array{id: string, object: string, usage_bytes: int, created_at: int, vector_store_id: string, status: string, last_error: ?array{code: string, message: string}, chunking_strategy: array{type: 'static', static: array{max_chunk_size_tokens: int, chunk_overlap_tokens: int}}|array{type: 'other'}}>, first_id: ?string, last_id: ?string, has_more: bool}  $attributes
     */
    public static function from(array $attributes, MetaInformation $meta): self
    {
        $data = array_map(fn (array $result): VectorStoreFileResponse => VectorStoreFileResponse::from(
            $result,
            $meta,
        ), $attributes['data']);

        return new self(
            $attributes['object'],
            $data,
            $attributes['first_id'],
            $attributes['last_id'],
            $attributes['has_more'],
            $meta,
        );
    }

    /**
     * {@inheritDoc}
     *
     * @return array{object: string, data: array<int, array{id: string, object: string, usage_bytes: int, created_at: int, vector_store_id: string, status: string, last_error: array{code: string, message: string}|null}>, first_id: string|null, last_id: string|null, has_more: bool}
     */
    public function toArray(): array
    {
        return [
            'object' => $this->object,
            'data' => array_map(
                static fn (VectorStoreFileResponse $response): array => $response->toArray(),
                $this->data,
            ),
            'first_id' => $this->firstId,
            'last_id' => $this->lastId,
            'has_more' => $this->hasMore,
        ];
    }
}
