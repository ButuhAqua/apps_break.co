<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RawMaterialStockMovementResource\Pages;
use App\Models\RawMaterialStockMovement;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class RawMaterialStockMovementResource extends Resource
{
    protected static ?string $model = RawMaterialStockMovement::class;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-path';
    protected static ?string $navigationGroup ='Inventory Bahan Baku';
    protected static ?string $navigationLabel = 'Mutasi Stok Bahan';
    protected static ?string $modelLabel = 'Mutasi Stok Bahan';
    protected static ?string $pluralModelLabel = 'Mutasi Stok Bahan';
    protected static ?int $navigationSort = 8;

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('created_at')
                    ->label('Tanggal')
                    ->dateTime('d M Y H:i')
                    ->sortable(),

                TextColumn::make('type')
                    ->label('Tipe')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'IN' => 'success',
                        'OUT' => 'danger',
                        'ADJUSTMENT' => 'warning',
                        'EXPIRED' => 'gray',
                        default => 'gray',
                    }),

                TextColumn::make('rawMaterial.name')
                    ->label('Bahan')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('batch.batch_number')
                    ->label('Batch')
                    ->searchable(),

                TextColumn::make('qty')
                    ->label('Qty')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('uom')
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('reference_id')
                    ->label('Ref ID'),

                TextColumn::make('notes')
                    ->label('Catatan')
                    ->wrap()
                    ->limit(50),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipe')
                    ->options([
                        'IN' => 'IN',
                        'OUT' => 'OUT',
                        'ADJUSTMENT' => 'ADJUSTMENT',
                        'EXPIRED' => 'EXPIRED',
                    ]),

                Tables\Filters\SelectFilter::make('raw_material_id')
                    ->label('Bahan')
                    ->relationship('rawMaterial', 'name')
                    ->searchable()
                    ->preload(),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Detail'),
            ])
            ->bulkActions([]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRawMaterialStockMovements::route('/'),
            'view' => Pages\ViewRawMaterialStockMovement::route('/{record}'),
        ];
    }
}