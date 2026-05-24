<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ProductStockMovementResource\Pages;
use App\Models\ProductStockMovement;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Filament\Tables\Columns\TextColumn;

class ProductStockMovementResource extends Resource
{
    protected static ?string $model = ProductStockMovement::class;

    protected static ?string $navigationIcon = 'heroicon-o-arrow-path';
    protected static ?string $navigationGroup ='Inventory Produk';
    protected static ?string $navigationLabel = 'Mutasi Stok Produk';
    protected static ?string $modelLabel = 'Mutasi Stok Produk';
    protected static ?string $pluralModelLabel = 'Mutasi Stok Produk';
    protected static ?int $navigationSort = 4;

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
                        'TRANSFER' => 'info',
                        default => 'gray',
                    }),

                TextColumn::make('product.name')
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('qty')
                    ->label('Qty')
                    ->numeric()
                    ->sortable(),

                TextColumn::make('uom')
                    ->label('Satuan')
                    ->badge(),

                TextColumn::make('from_location')
                    ->label('Dari')
                    ->default('-')
                    ->badge(),

                TextColumn::make('to_location')
                    ->label('Ke')
                    ->default('-')
                    ->badge(),

                TextColumn::make('reference_id')
                    ->label('Ref ID'),

                TextColumn::make('notes')
                    ->label('Catatan')
                    ->wrap()
                    ->limit(60),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('type')
                    ->label('Tipe')
                    ->options([
                        'IN' => 'IN',
                        'OUT' => 'OUT',
                        'TRANSFER' => 'TRANSFER',
                    ]),

                Tables\Filters\SelectFilter::make('product_id')
                    ->label('Produk')
                    ->relationship('product', 'name')
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
            'index' => Pages\ListProductStockMovements::route('/'),
            'view' => Pages\ViewProductStockMovement::route('/{record}'),
        ];
    }
}