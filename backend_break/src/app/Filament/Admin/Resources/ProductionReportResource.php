<?php

namespace App\Filament\Admin\Resources;

use App\Filament\Admin\Resources\ProductionReportResource\Pages;
use App\Models\Product;
use App\Models\ProductStockMovement;
use App\Models\Inventory;
use App\Models\ProductionReport;
use App\Models\RawMaterial;
use App\Models\RawMaterialInventoryBatch;
use App\Models\RawMaterialStockMovement;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;

class ProductionReportResource extends Resource
{
    protected static ?string $model = ProductionReport::class;

    protected static ?string $navigationIcon = 'heroicon-o-beaker';
    protected static ?string $navigationGroup = 'Produksi';
    protected static ?string $navigationLabel = 'Laporan Produksi';
    protected static ?string $modelLabel = 'Laporan Produksi';
    protected static ?string $pluralModelLabel = 'Laporan Produksi';

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('Informasi Produksi')
                ->schema([
                    Forms\Components\TextInput::make('report_number')
                        ->label('Nomor Laporan')
                        ->default(fn () => 'PRD-' . now()->format('Ymd-His'))
                        ->required()
                        ->unique(ignoreRecord: true),

                    Forms\Components\DatePicker::make('production_date')
                        ->label('Tanggal Produksi')
                        ->default(now())
                        ->required(),

                    Forms\Components\Select::make('status')
                        ->label('Status')
                        ->options([
                            'Draft' => 'Draft',
                            'Submitted' => 'Submitted',
                            'Disetujui' => 'Disetujui',
                            'Selesai' => 'Selesai',
                            'Ditolak' => 'Ditolak',
                        ])
                        ->default('Submitted')
                        ->required(),

                    Forms\Components\Textarea::make('notes')
                        ->label('Catatan')
                        ->rows(3)
                        ->columnSpanFull(),
                ])
                ->columns(2),

            Forms\Components\Section::make('Bahan Baku yang Dipakai')
                ->schema([
                    Forms\Components\Repeater::make('materialUsages')
                        ->relationship()
                        ->schema([
                            Forms\Components\Select::make('raw_material_id')
                                ->label('Bahan Baku')
                                ->relationship('rawMaterial', 'name')
                                ->searchable()
                                ->preload()
                                ->required()
                                ->reactive()
                                ->afterStateUpdated(function ($state, callable $set) {
                                    $material = RawMaterial::find($state);

                                    if ($material) {
                                        $set('uom', $material->uom);
                                    }
                                }),

                            Forms\Components\TextInput::make('qty')
                                ->label('Qty Dipakai')
                                ->numeric()
                                ->required()
                                ->minValue(1),

                            Forms\Components\TextInput::make('uom')
                                ->label('Satuan')
                                ->readOnly()
                                ->required(),
                        ])
                        ->columns(3)
                        ->defaultItems(1)
                        ->columnSpanFull(),
                ]),

            Forms\Components\Section::make('Produk Jadi')
                ->schema([
                    Forms\Components\Repeater::make('finishedProducts')
                        ->relationship()
                        ->schema([
                            Forms\Components\Select::make('product_id')
                                ->label('Produk')
                                ->relationship('product', 'name')
                                ->searchable()
                                ->preload()
                                ->required(),

                            Forms\Components\TextInput::make('qty')
                                ->label('Qty Jadi')
                                ->numeric()
                                ->required()
                                ->minValue(1),

                            Forms\Components\TextInput::make('uom')
                                ->label('Satuan')
                                ->default('pcs')
                                ->required(),
                        ])
                        ->columns(3)
                        ->defaultItems(1)
                        ->columnSpanFull(),
                ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('report_number')
                    ->label('Nomor Laporan')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('production_date')
                    ->label('Tanggal Produksi')
                    ->date('d M Y')
                    ->sortable(),

                TextColumn::make('status')
                    ->label('Status')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'Draft' => 'gray',
                        'Submitted' => 'info',
                        'Disetujui' => 'warning',
                        'Selesai' => 'success',
                        'Ditolak' => 'danger',
                        default => 'gray',
                    }),

                TextColumn::make('user.name')
                    ->label('Dibuat Oleh')
                    ->default('-'),

                TextColumn::make('created_at')
                    ->label('Dibuat')
                    ->dateTime('d M Y H:i')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->actions([
                Tables\Actions\ViewAction::make()->label('Detail'),

                Tables\Actions\EditAction::make()
                    ->label('Edit')
                    ->visible(fn ($record) => in_array($record->status, ['Draft', 'Submitted'])),

                Action::make('approve')
                    ->label('Approve')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->visible(fn ($record) => $record->status === 'Submitted')
                    ->action(function ($record) {
                        try {
                            self::approveProductionReport($record);

                            Notification::make()
                                ->title('Laporan produksi berhasil di-approve')
                                ->body('Stok bahan baku berhasil dikurangi dengan metode FEFO.')
                                ->success()
                                ->send();
                        } catch (\Throwable $e) {
                            Notification::make()
                                ->title('Gagal approve laporan produksi')
                                ->body($e->getMessage())
                                ->danger()
                                ->send();
                        }
                    }),

                Action::make('complete')

                    ->label('Selesaikan')
                
                    ->icon('heroicon-o-check-badge')
                
                    ->color('success')

                    ->successRedirectUrl(
                        fn () =>
                            ProductionReportResource::getUrl('index')
                    )
                
                    ->visible(
                        fn ($record) =>
                            $record->status === 'Disetujui'
                    )
                
                    ->form(function ($record): array {

                        $forms = [];
                    
                        foreach ($record->finishedProducts as $item) {
                    
                            $forms[] =
                                Forms\Components\DatePicker::make(
                                    'expired_' . $item->product_id
                                )
                    
                                ->label(
                                    'Expired ' .
                                    $item->product?->name
                                )
                    
                                ->required();
                        }
                    
                        return $forms;
                    })
                
                    ->action(function (
                        $record,
                        array $data
                    ) {
                
                        try {
                
                            DB::transaction(function () use ($record, $data) {

                                foreach (
                                    $record->finishedProducts
                                    as $item
                                ) {
                            
                                    $expiredDate =
                                        $data[
                                            'expired_' .
                                            $item->product_id
                                        ];
                            
                                    $inventory =
                                        Inventory::firstOrCreate(
                                            [
                                                'product_id' =>
                                                    $item->product_id,
                            
                                                'location' =>
                                                    'Gudang Produksi',
                                            ],
                                            [
                                                'stock' => 0,
                                            ]
                                        );
                            
                                    $inventory->increment(
                                        'stock',
                                        $item->qty
                                    );
                            
                                    \App\Models\ProductInventoryBatch::create([
                            
                                        'product_id' =>
                                            $item->product_id,
                            
                                        'inventory_id' =>
                                            $inventory->id,
                            
                                        'batch_number' =>
                                            'PRD-' .
                                            now()->format('YmdHis') .
                                            '-' .
                                            $item->product_id,
                            
                                        'production_date' =>
                                            now(),
                            
                                        'expired_date' =>
                                            $expiredDate,
                            
                                        'qty_in' =>
                                            $item->qty,
                            
                                        'qty_remaining' =>
                                            $item->qty,
                            
                                        'uom' =>
                                            $item->uom,
                            
                                        'notes' =>
                                            'Batch produksi otomatis dari laporan #' .
                                            $record->id,
                                    ]);
                            
                                    ProductStockMovement::create([
                            
                                        'product_id' =>
                                            $item->product_id,
                            
                                        'type' => 'IN',
                            
                                        'qty' =>
                                            $item->qty,
                            
                                        'uom' =>
                                            $item->uom,
                            
                                        'to_location' =>
                                            'Gudang Produksi',
                            
                                        'reference_type' =>
                                            ProductionReport::class,
                            
                                        'reference_id' =>
                                            $record->id,
                            
                                        'notes' =>
                                            'Produk masuk otomatis dari laporan produksi #' .
                                            $record->id,
                            
                                        'user_id' =>
                                            auth()->id(),
                                    ]);
                                }
                            
                                $record->update([
                                    'status' => 'Selesai',
                                ]);
                            });
                
                        } catch (\Throwable $e) {
                        
                            Notification::make()
                        
                                ->title(
                                    'Gagal menyelesaikan laporan'
                                )
                        
                                ->body(
                                    $e->getMessage()
                                )
                        
                                ->danger()
                        
                                ->send();
                        }
                    }),

                Action::make('reject')
                    ->label('Reject')
                    ->icon('heroicon-o-x-circle')
                    ->color('danger')
                    ->requiresConfirmation()
                    ->visible(fn ($record) => $record->status === 'Submitted')
                    ->action(function ($record) {
                        $record->update([
                            'status' => 'Ditolak',
                        ]);
                    }),
            ])
            ->bulkActions([]);
    }

    protected static function approveProductionReport(ProductionReport $record): void
    {
        DB::transaction(function () use ($record) {
            $record->load([
                'materialUsages.rawMaterial',
                'finishedProducts.product',
            ]);

            $record->update([
                'status' => 'Disetujui',
            ]);
        });
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListProductionReports::route('/'),
            'create' => Pages\CreateProductionReport::route('/create'),
            'view' => Pages\ViewProductionReport::route('/{record}'),
            'edit' => Pages\EditProductionReport::route('/{record}/edit'),
        ];
    }
}