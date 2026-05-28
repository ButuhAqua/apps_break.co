<?php

namespace App\Filament\Admin\Widgets;

use App\Models\ProductStockMovement;
use Filament\Widgets\ChartWidget;

class TopSellingProductsChart extends ChartWidget
{
    protected static ?string $heading =
        'Top Selling Products';

    protected static ?int $sort = 2;

    protected int|string|array $columnSpan = 1;

    protected static ?string $maxHeight =
        '300px';

    protected function getData(): array
    {
        $data = ProductStockMovement::query()

            ->where('type', 'OUT')

            ->selectRaw('
                product_id,
                SUM(qty) as total_sold
            ')

            ->with('product')

            ->groupBy('product_id')

            ->orderByDesc('total_sold')

            ->limit(5)

            ->get();

        return [

            'datasets' => [
                [
                    'label' => 'Total Sold',

                    'data' => $data
                        ->pluck('total_sold')
                        ->toArray(),
                ],
            ],

            'labels' => $data
                ->map(function ($item) {

                    return $item->product?->name
                        ?? 'Unknown';
                })
                ->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'bar';
    }
}