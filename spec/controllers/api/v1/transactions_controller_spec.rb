# frozen_string_literal: true

RSpec.describe Api::V1::TransactionsController, type: :controller do
  let(:user) { create(:user) }
  
  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:authenticate_request).and_return(true)
    allow(controller).to receive(:authenticate_user!).and_return(true)
  end

  describe 'GET #index' do
    context 'when user has transactions' do
      let!(:expense_category) { create(:category, category_type: :expense, name: "Food-#{SecureRandom.hex(4)}") }
      let!(:income_category) { create(:category, category_type: :income, name: "Salary-#{SecureRandom.hex(4)}") }
      let!(:transaction1) { create(:transaction, user: user, category: expense_category, amount: 100, transaction_date: Date.new(2025, 12, 2)) }
      let!(:transaction2) { create(:transaction, user: user, category: expense_category, amount: 50, transaction_date: Date.new(2025, 12, 1)) }
      let!(:income) { create(:transaction, user: user, category: income_category, amount: 500, transaction_date: Date.new(2025, 12, 1)) }

      it 'returns success status' do
        get :index, params: { page: 1 }
        
        expect(response).to have_http_status(:ok)
      end

      it 'returns transactions ordered by date descending' do
        get :index, params: { page: 1 }
        
        body = JSON.parse(response.body)
        transaction_ids = body['transactions'].map { |t| t['id'] }
        expect(transaction_ids).to eq([transaction1.id, transaction2.id, income.id])
      end

      it 'includes transaction details' do
        get :index, params: { page: 1 }

        body = JSON.parse(response.body)
        first_transaction = body['transactions'].first

        expect(first_transaction).to include(
          'id' => transaction1.id,
          'amount' => transaction1.amount.to_s,
          'category_name' => expense_category.name,
          'transaction_date' => '2025-12-02'
        )
      end

      it 'calculates total expenses correctly' do
        get :index, params: { page: 1 }

        body = JSON.parse(response.body)
        expect(body['pagination']['total_expense'].to_f).to eq(150.0)
      end

      it 'calculates total income correctly' do
        get :index, params: { page: 1 }

        body = JSON.parse(response.body)
        expect(body['pagination']['total_income'].to_f).to eq(500.0)
      end

      it 'includes pagination metadata' do
        get :index, params: { page: 1 }
        
        body = JSON.parse(response.body)
        pagination = body['pagination']
        
        expect(pagination).to include(
          'current_page' => 1,
          'total_pages' => 1,
          'total_count' => 3,
          'per_page' => 10
        )
      end
    end

    context 'when user has no transactions' do
      it 'returns empty transactions list' do
        get :index, params: { page: 1 }
        
        body = JSON.parse(response.body)
        expect(body['transactions']).to be_empty
      end

      it 'returns zero for totals' do
        get :index, params: { page: 1 }

        body = JSON.parse(response.body)
        expect(body['pagination']['total_expense'].to_f).to eq(0)
        expect(body['pagination']['total_income'].to_f).to eq(0)
      end
    end

    context 'when requesting specific page' do
      before do
        create_list(:transaction, 15, user: user, category: create(:category))
      end

      it 'returns correct page of results' do
        get :index, params: { page: 2 }
        
        body = JSON.parse(response.body)
        expect(body['pagination']['current_page']).to eq(2)
        expect(body['transactions'].size).to eq(5)
      end
    end
  end

  describe 'POST #create' do
    let(:category) { create(:category) }
    let(:valid_params) do
      {
        transaction: {
          category_id: category.id,
          user_id: user.id,
          amount: 50,
          transaction_date: '2025-12-01',
          note: 'lunch'
        }
      }
    end

    it 'creates a new transaction' do
      expect {
        post :create, params: valid_params
      }.to change(Transaction, :count).by(1)
    end

    it 'returns created status' do
      post :create, params: valid_params
      
      expect(response).to have_http_status(:created)
    end

    it 'returns the created transaction id' do
      post :create, params: valid_params
      
      body = JSON.parse(response.body)
      expect(body['id']).to be_present
    end

    it 'associates transaction with current user' do
      post :create, params: valid_params
      
      created_transaction = Transaction.last
      expect(created_transaction.user).to eq(user)
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { transaction: { amount: nil } }
      end

      it 'returns unprocessable entity status' do
        post :create, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not create a transaction' do
        expect {
          post :create, params: invalid_params
        }.not_to change(Transaction, :count)
      end
    end
  end

  describe 'GET #show' do
    context 'when transaction belongs to current user' do
      let(:transaction) { create(:transaction, user: user) }

      it 'returns success status' do
        get :show, params: { id: transaction.id }
        
        expect(response).to have_http_status(:ok)
      end

      it 'returns transaction details' do
        get :show, params: { id: transaction.id }

        body = JSON.parse(response.body)
        expect(body['id']).to eq(transaction.id)
        expect(body['amount'].to_f).to eq(transaction.amount)
      end
    end

    context 'when transaction belongs to another user' do
      let(:other_user) { create(:user) }
      let(:transaction) { create(:transaction, user: other_user) }

      it 'returns forbidden status' do
        get :show, params: { id: transaction.id }
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not return transaction details' do
        get :show, params: { id: transaction.id }
        
        body = JSON.parse(response.body)
        expect(body['id']).to be_nil
      end
    end

    context 'when transaction does not exist' do
      it 'returns not found status' do
        get :show, params: { id: -1 }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT #update' do
    let(:transaction) { create(:transaction, user: user, amount: 30) }
    let(:update_params) do
      { id: transaction.id, transaction: { amount: 40 } }
    end

    context 'when transaction belongs to current user' do
      it 'updates the transaction' do
        put :update, params: update_params
        
        expect(transaction.reload.amount).to eq(40)
      end

      it 'returns success status' do
        put :update, params: update_params
        
        expect(response).to have_http_status(:ok)
      end

      it 'returns updated transaction' do
        put :update, params: update_params

        body = JSON.parse(response.body)
        expect(body['transaction']['amount'].to_f).to eq(40.0)
      end
    end

    context 'when transaction belongs to another user' do
      let(:other_user) { create(:user) }
      let(:transaction) { create(:transaction, user: other_user, amount: 30) }

      it 'returns forbidden status' do
        put :update, params: update_params
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not update the transaction' do
        put :update, params: update_params
        
        expect(transaction.reload.amount).to eq(30)
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { id: transaction.id, transaction: { amount: -100 } }
      end

      it 'returns unprocessable entity status' do
        put :update, params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the transaction' do
        put :update, params: invalid_params
        
        expect(transaction.reload.amount).to eq(30)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:transaction) { create(:transaction, user:) }

    context 'when transaction belongs to current user' do
      it 'deletes the transaction' do
        expect {
          delete :destroy, params: { id: transaction.id }
        }.to change(Transaction, :count).by(-1)
      end

      it 'returns success status' do
        delete :destroy, params: { id: transaction.id }
        
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when transaction belongs to another user' do
      let(:other_user) { create(:user) }
      let!(:transaction) { create(:transaction, user: other_user) }

      it 'returns forbidden status' do
        delete :destroy, params: { id: transaction.id }
        
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not delete the transaction' do
        expect {
          delete :destroy, params: { id: transaction.id }
        }.not_to change(Transaction, :count)
      end
    end

    context 'when transaction does not exist' do
      it 'returns not found status' do
        delete :destroy, params: { id: -1 }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
