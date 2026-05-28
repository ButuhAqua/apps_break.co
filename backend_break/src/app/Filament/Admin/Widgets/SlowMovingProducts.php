<?php

namespace App\Filament\Admin\Widgets;

use App\Models\Product;
use Filament\Tables;
use Filament\Widgets\TableWidget as BaseWidget;
use Illuminate\Database\Eloquent\Builder;

class SlowMovingProducts extends BaseWidget
{
    protected static ?string $heading =
        'Slow Moving Products';

    protected static ?int $sort = 4;

    protected int|string|array $columnSpan = 1;

    public function table(
        Tables\Table $table
    ): Tables\Table {

        return $table

            ->query(

                Product::query()

                    ->with([
                        'stockMovements' => function ($query) {

                            $query
                                ->where('type', 'OUT')
                                ->latest();
                        }
                    ])
            )

            ->columns([

                Tables\Columns\TextColumn::make(
                    'name'
                )
                    ->label('Product'),

                Tables\Columns\TextColumn::make(
                    'last_sold'
                )
                    ->label('Last Sold')
                    ->getStateUsing(function (
                        $record
                    ) {

                        $lastMovement =
                            $record->stockMovements
                                ->first();

                        if (!$lastMovement) {
                            return 'Never Sold';
                        }

                        return $lastMovement
                            ->created_at
                            ->diffForHumans();
                    }),

                Tables\Columns\BadgeColumn::make(
                    'status'
                )
                    ->getStateUsing(function (
                        $record
                    ) {

                        $lastMovement =
                            $record->stockMovements
                                ->first();

                        if (!$lastMovement) {
                            return 'No Sales';
                        }

                        $days =
                            now()->diffInDays(
                                $lastMovement->created_at
                            );

                        if ($days >= 14) {
                            return 'Slow';
                        }

                        return 'Active';
                    })
                    ->colors([
                        'danger' => 'Slow',
                        'warning' => 'No Sales',
                        'success' => 'Active',
                    ]),
            ])

            ->defaultSort('name')

            ->paginated(false);
    }
}