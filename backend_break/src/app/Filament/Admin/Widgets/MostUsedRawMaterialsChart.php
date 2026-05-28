<?php

namespace App\Filament\Admin\Widgets;

use App\Models\RawMaterialStockMovement;
use Filament\Widgets\ChartWidget;

class MostUsedRawMaterialsChart extends ChartWidget
{
    protected static ?string $heading =
        'Most Used Raw Materials';

    protected static ?int $sort = 3;

    protected int|string|array $columnSpan = 1;

    protected static ?string $maxHeight =
        '300px';

    protected function getData(): array
    {
        $data = RawMaterialStockMovement::query()

            ->where('type', 'OUT')

            ->selectRaw('
                raw_material_id,
                SUM(qty) as total_used
            ')

            ->with('rawMaterial')

            ->groupBy('raw_material_id')

            ->orderByDesc('total_used')

            ->limit(5)

            ->get();

        return [

            'datasets' => [
                [
                    'label' => 'Total Used',

                    'data' => $data
                        ->pluck('total_used')
                        ->toArray(),
                ],
            ],

            'labels' => $data
                ->map(function ($item) {

                    return $item->rawMaterial?->name
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