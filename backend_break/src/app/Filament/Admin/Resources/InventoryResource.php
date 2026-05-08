<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\InventoryResource\Pages;
use App\Models\Inventory;
use App\Models\ProductStockMovement;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Actions\Action;
use Filament\Tables\Table;
use Illuminate\Support\Facades\DB;

class InventoryResource extends Resource
{
    protected static ?string $model = Inventory::class;

    protected static ?string $navigationIcon = 'heroicon-o-archive-box';
    protected static ?string $navigationLabel = 'Inventories';
    protected static ?string $navigationGroup = 'Inventory';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('product_id')
                    ->label('Produk')
                    ->relationship('product', 'name')
                    ->searchable()
                    ->preload()
                    ->required(),

                Forms\Components\Select::make('location')
                    ->label('Lokasi')
                    ->options([
                        'Basecamp' => 'Basecamp',
                        'Gerobak A' => 'Gerobak A',
                        'Gerobak B' => 'Gerobak B',
                    ])
                    ->required(),

                Forms\Components\TextInput::make('stock')
                    ->label('Stok')
                    ->numeric()
                    ->required()
                    ->minValue(0),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('product.name')
                    ->label('Produk')
                    ->searchable()
                    ->sortable(),

                Tables\Columns\TextColumn::make('product.sku')
                    ->label('SKU')
                    ->searchable(),

                Tables\Columns\TextColumn::make('location')
                    ->label('Lokasi')
                    ->badge()
                    ->sortable(),

                Tables\Columns\TextColumn::make('stock')
                    ->label('Stok')
                    ->sortable(),

                Tables\Columns\TextColumn::make('product.uom')
                    ->label('Satuan'),

                Tables\Columns\TextColumn::make('updated_at')
                    ->label('Terakhir Update')
                    ->dateTime()
                    ->sortable(),
            ])
            ->filters([
                Tables\Filters\SelectFilter::make('location')
                    ->label('Lokasi')
                    ->options([
                        'Basecamp' => 'Basecamp',
                        'Gerobak A' => 'Gerobak A',
                        'Gerobak B' => 'Gerobak B',
                    ]),
            ])
            ->actions([
                Action::make('distribute')
                    ->label('Distribusi')
                    ->icon('heroicon-o-truck')
                    ->color('info')
                    ->visible(fn ($record) => $record->location === 'Basecamp' && $record->stock > 0)
                    ->form([
                        Forms\Components\Select::make('to_location')
                            ->label('Tujuan Gerobak')
                            ->options([
                                'Gerobak A' => 'Gerobak A',
                                'Gerobak B' => 'Gerobak B',
                            ])
                            ->required(),

                        Forms\Components\TextInput::make('qty')
                            ->label('Qty Distribusi')
                            ->numeric()
                            ->required()
                            ->minValue(1),
                    ])
                    ->action(function ($record, array $data) {
                        DB::transaction(function () use ($record, $data) {
                            $qty = (int) $data['qty'];
                            $toLocation = $data['to_location'];

                            if ($qty <= 0) {
                                throw new \Exception('Qty harus lebih dari 0.');
                            }

                            if ($record->stock < $qty) {
                                throw new \Exception('Stok Basecamp tidak cukup.');
                            }

                            $record->decrement('stock', $qty);

                            $targetInventory = Inventory::firstOrCreate(
                                [
                                    'product_id' => $record->product_id,
                                    'location' => $toLocation,
                                ],
                                [
                                    'stock' => 0,
                                ]
                            );

                            $targetInventory->increment('stock', $qty);

                            ProductStockMovement::create([
                                'product_id' => $record->product_id,
                                'type' => 'TRANSFER',
                                'qty' => $qty,
                                'uom' => $record->product?->uom ?? 'pcs',
                                'from_location' => 'Basecamp',
                                'to_location' => $toLocation,
                                'reference_type' => Inventory::class,
                                'reference_id' => $record->id,
                                'notes' => 'Distribusi produk dari Basecamp ke ' . $toLocation,
                                'user_id' => auth()->id(),
                            ]);
                        });

                        Notification::make()
                            ->title('Distribusi berhasil')
                            ->success()
                            ->send();
                    }),

                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListInventories::route('/'),
            'create' => Pages\CreateInventory::route('/create'),
            'edit' => Pages\EditInventory::route('/{record}/edit'),
        ];
    }
}