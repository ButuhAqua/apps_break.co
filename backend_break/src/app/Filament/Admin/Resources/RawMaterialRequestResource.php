<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\RawMaterialRequestResource\Pages;
use App\Models\RawMaterialInventoryBatch;
use App\Models\RawMaterialRequest;
use App\Models\RawMaterialStockMovement;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\DB;

class RawMaterialRequestResource extends Resource
{
    protected static ?string $model = RawMaterialRequest::class;

    protected static ?string $navigationIcon = 'heroicon-o-clipboard-document-list';

    protected static ?string $navigationLabel = 'Pengajuan Bahan Baku';

    protected static ?string $modelLabel = 'Pengajuan Bahan Baku';

    protected static ?string $pluralModelLabel = 'Pengajuan Bahan Baku';

    protected static ?string $navigationGroup ='Pengajuan Bahan Baku';

    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Informasi Pengajuan')
                    ->schema([
                        Forms\Components\TextInput::make('title')
                            ->label('Judul')
                            ->required()
                            ->maxLength(255),

                        Forms\Components\TextInput::make('request_type')
                            ->label('Jenis Pengajuan')
                            ->default('Pembelian Bahan Baku')
                            ->required(),

                        Forms\Components\Select::make('priority')
                            ->label('Prioritas')
                            ->options([
                                'Normal' => 'Normal',
                                'Mendesak' => 'Mendesak',
                            ])
                            ->default('Normal')
                            ->required(),

                        Forms\Components\DatePicker::make('request_date')
                            ->label('Tanggal Pengajuan')
                            ->required(),

                        Forms\Components\TextInput::make('purchase_location')
                            ->label('Lokasi Pembelian')
                            ->maxLength(255),

                        Forms\Components\Select::make('status')
                            ->label('Status')
                            ->options([
                                'Menunggu' => 'Menunggu',
                                'Disetujui' => 'Disetujui',
                                'Selesai' => 'Selesai',
                                'Ditolak' => 'Ditolak',
                            ])
                            ->default('Menunggu')
                            ->required(),

                        Forms\Components\Textarea::make('notes')
                            ->label('Catatan')
                            ->rows(3)
                            ->columnSpanFull(),
                    ])
                    ->columns(2),

                Forms\Components\Section::make('Item Bahan Baku')
                    ->schema([
                        Forms\Components\Repeater::make('items')
                            ->relationship()
                            ->label('Daftar Item')
                            ->schema([
                                Forms\Components\TextInput::make('name')
                                    ->label('Nama Bahan')
                                    ->required(),

                                Forms\Components\TextInput::make('category')
                                    ->label('Kategori')
                                    ->default('Bahan Baku')
                                    ->required(),

                                Forms\Components\TextInput::make('uom')
                                    ->label('Satuan')
                                    ->required(),

                                Forms\Components\TextInput::make('qty')
                                    ->label('Jumlah')
                                    ->numeric()
                                    ->required(),
                            ])
                            ->columns(4)
                            ->defaultItems(1)
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('title')
                    ->label('Judul')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('request_type')
                    ->label('Jenis')
                    ->searchable(),

                TextColumn::make('priority')
                    ->label('Prioritas')
                    ->badge()
                    ->sortable(),

                TextColumn::make('request_date')
                    ->label('Tanggal')
                    ->date()
                    ->sortable(),

                TextColumn::make('purchase_location')
                    ->label('Lokasi Pembelian')
                    ->searchable()
                    ->toggleable(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Menunggu' => 'warning',
                        'Disetujui' => 'info',
                        'Selesai' => 'success',
                        'Ditolak' => 'danger',
                        default => 'gray',
                    })
                    ->sortable(),

                TextColumn::make('user.name')
                    ->label('Pengaju')
                    ->searchable()
                    ->default('-'),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->label('Status')
                    ->options([
                        'Menunggu' => 'Menunggu',
                        'Disetujui' => 'Disetujui',
                        'Selesai' => 'Selesai',
                        'Ditolak' => 'Ditolak',
                    ]),

                Tables\Filters\SelectFilter::make('priority')
                    ->label('Prioritas')
                    ->options([
                        'Normal' => 'Normal',
                        'Mendesak' => 'Mendesak',
                    ]),
            ])
            ->actions([
                Tables\Actions\ViewAction::make()
                    ->label('Detail'),

                Tables\Actions\EditAction::make()
                    ->label('Edit'),

                Action::make('approve')
                    ->label('Setujui')
                    ->icon('heroicon-o-check-circle')
                    ->color('info')
                    ->requiresConfirmation()
                    ->visible(fn ($record) => $record->status === 'Menunggu')
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'Disetujui',
                        ]);
                    }),

                Action::make('reject')
                    ->label('Tolak')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn ($record) => $record->status === 'Menunggu')
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'Ditolak',
                        ]);
                    }),

                Action::make('done')
                    ->label('Selesai')
                    ->icon('heroicon-o-check-badge')
                    ->color('success')
                    ->visible(fn ($record) => $record->status === 'Disetujui')
                    ->form(fn ($record) => [
                        Forms\Components\TextInput::make('supplier')
                            ->label('Supplier')
                            ->maxLength(255),

                        Forms\Components\Textarea::make('notes')
                            ->label('Catatan Batch')
                            ->rows(2),

                        Forms\Components\Repeater::make('items')
                            ->label('Expired Date Per Bahan')
                            ->schema([
                                Forms\Components\Hidden::make('item_id'),

                                Forms\Components\TextInput::make('name')
                                    ->label('Nama Bahan')
                                    ->disabled(),

                                Forms\Components\TextInput::make('qty')
                                    ->label('Qty')
                                    ->disabled(),

                                Forms\Components\TextInput::make('uom')
                                    ->label('Satuan')
                                    ->disabled(),

                                Forms\Components\DatePicker::make('expired_date')
                                    ->label('Tanggal Expired')
                                    ->required(),
                            ])
                            ->default(
                                $record->items->map(fn ($item) => [
                                    'item_id' => $item->id,
                                    'name' => $item->name,
                                    'qty' => $item->qty,
                                    'uom' => $item->uom,
                                    'expired_date' => null,
                                ])->toArray()
                            )
                            ->columns(4)
                            ->addable(false)
                            ->deletable(false)
                            ->reorderable(false),
                    ])
                    ->action(function ($record, array $data) {
                        DB::transaction(function () use ($record, $data) {
                            $record->load('items');

                            foreach ($data['items'] as $formItem) {
                                $requestItem = $record->items->firstWhere('id', $formItem['item_id']);

                                if (! $requestItem) {
                                    continue;
                                }

                                $batch = RawMaterialInventoryBatch::create([
                                    'raw_material_id' => $requestItem->raw_material_id,
                                    'batch_number' => self::generateBatchNumber(),
                                    'received_date' => now()->toDateString(),
                                    'expired_date' => $formItem['expired_date'],
                                    'qty_in' => $requestItem->qty,
                                    'qty_remaining' => $requestItem->qty,
                                    'uom' => $requestItem->uom,
                                    'supplier' => $data['supplier'] ?? null,
                                    'notes' => $data['notes'] ?? 'Otomatis dari pengajuan #' . $record->id,
                                ]);

                                RawMaterialStockMovement::create([
                                    'raw_material_id' => $requestItem->raw_material_id,
                                    'raw_material_inventory_batch_id' => $batch->id,
                                    'type' => 'IN',
                                    'qty' => $requestItem->qty,
                                    'uom' => $requestItem->uom,
                                    'reference_type' => RawMaterialRequest::class,
                                    'reference_id' => $record->id,
                                    'notes' => 'Stock masuk otomatis dari pengajuan #' . $record->id,
                                    'user_id' => auth()->id(),
                                ]);
                            }

                            $record->update([
                                'status' => 'Selesai',
                            ]);
                        });
                    }),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    protected static function generateBatchNumber(): string
    {
        $date = now()->format('Ymd');
        $prefix = "RM-{$date}";

        $number = RawMaterialInventoryBatch::where('batch_number', 'like', "{$prefix}-%")
            ->count() + 1;

        do {
            $batchNumber = "{$prefix}-" . str_pad($number, 3, '0', STR_PAD_LEFT);
            $number++;
        } while (RawMaterialInventoryBatch::where('batch_number', $batchNumber)->exists());

        return $batchNumber;
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListRawMaterialRequests::route('/'),
            'create' => Pages\CreateRawMaterialRequest::route('/create'),
            'view' => Pages\ViewRawMaterialRequest::route('/{record}'),
            'edit' => Pages\EditRawMaterialRequest::route('/{record}/edit'),
        ];
    }
}