<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RawMaterialInventoryResource\Pages;
use App\Models\RawMaterial;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class RawMaterialInventoryResource extends Resource
{
    protected static ?string $model = RawMaterial::class;

    protected static ?string $navigationIcon = 'heroicon-o-chart-bar-square';

    protected static ?string $navigationGroup ='Inventory Bahan Baku';

    protected static ?string $navigationLabel = 'Inventory Bahan Baku';

    protected static ?string $modelLabel = 'Inventory Bahan Baku';

    protected static ?string $pluralModelLabel = 'Inventory Bahan Baku';

    protected static ?int $navigationSort = 6;

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Bahan Baku')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('category')
                    ->label('Kategori')
                    ->badge()
                    ->sortable(),

                TextColumn::make('total_stock')
                    ->label('Total Stock')
                    ->getStateUsing(function ($record) {
                        return $record->inventoryBatches()
                            ->where('qty_remaining', '>', 0)
                            ->sum('qty_remaining');
                    })
                    ->sortable(),

                TextColumn::make('uom')
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('batch_count')
                    ->label('Jumlah Batch')
                    ->getStateUsing(function ($record) {
                        return $record->inventoryBatches()
                            ->where('qty_remaining', '>', 0)
                            ->count();
                    }),

                TextColumn::make('nearest_expired')
                    ->label('Expired Terdekat')
                    ->getStateUsing(function ($record) {
                        $batch = $record->inventoryBatches()
                            ->where('qty_remaining', '>', 0)
                            ->whereNotNull('expired_date')
                            ->orderBy('expired_date')
                            ->first();

                        return $batch?->expired_date?->format('d M Y') ?? '-';
                    }),

                TextColumn::make('stock_status')
                    ->label('Status')
                    ->badge()
                    ->getStateUsing(function ($record) {
                        $totalStock = $record->inventoryBatches()
                            ->where('qty_remaining', '>', 0)
                            ->sum('qty_remaining');

                        if ($totalStock <= 0) {
                            return 'Kosong';
                        }

                        $nearestBatch = $record->inventoryBatches()
                            ->where('qty_remaining', '>', 0)
                            ->whereNotNull('expired_date')
                            ->orderBy('expired_date')
                            ->first();

                        if (! $nearestBatch) {
                            return 'Aman';
                        }

                        if ($nearestBatch->expired_date->isPast()) {
                            return 'Ada Expired';
                        }

                        if (
                            now()->lte($nearestBatch->expired_date) &&
                            now()->diffInDays($nearestBatch->expired_date) <= 7
                        ) {
                            return 'Hampir Expired';
                        }

                        return 'Aman';
                    })
                    ->color(fn (string $state): string => match ($state) {
                        'Kosong' => 'gray',
                        'Ada Expired' => 'danger',
                        'Hampir Expired' => 'warning',
                        'Aman' => 'success',
                        default => 'gray',
                    }),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Detail Batch'),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRawMaterialInventories::route('/'),
            'view' => Pages\ViewRawMaterialInventory::route('/{record}'),
        ];
    }
}