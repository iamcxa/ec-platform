OrderController =
  # order building section
  create : (req, res)  ->
    # 1. 透過 Productid 找到 model product --- ok
    # 2. 檢查 user 是否存在，若否進行建立  ---
    # 3. 建立訂單 order                    ---
    # order = {
    #   id: '11223344'
    #   quantity: 10
    #
    #   user: {
    #     username: 'test'
    #     email: 'test@gmail.com'
    #     mobile: '0911-111-111'
    #     address: '台灣省台灣市台灣路'
    #   }
    #
    #   product: {
    #     name: '柚子'
    #     desctipt: '又大又好吃'
    #     stockQuantity: 10
    #     price: 100
    #     id: 1
    #   }
    # }
    ##############################################
    # get params
    newOrder = req.body
    quantity = req.body.quantity
    jProduct = newOrder.product
    jUser = newOrder.user

    # outputs
    result = {
      order:null
      success:null
    }

    # console outputs
    console.log '=====================>'
    console.log ' user:', jUser
    console.log ' product:', jProduct
    console.log '=====================>'

    # step 1 : get product by given id.
    doFindProduct = (done) ->
      db.Product.findById(1).then (findProduct) ->
        #
        console.log '=====================>'
        console.log ' product in db:',findProduct
        console.log '=====================>'

        #
        return done(msg: '找不到商品！ 請確認商品ID！') if !findProduct
        return done(msg: '商品售鑿！') if findProduct.stockQuantity is 0
        return done(msg: '商品數量不足！') if findProduct.stockQuantity < quantity
        done(null)

    # step 2 : check user whether exists.
    doFindOrCreateUser = (done) ->
      #db.User.findOrCreate({where: {email:jUser.email}, defaults:jUser}).then (thisUser) ->
      db.User.findOne({where: {email:jUser.email}}).then (thisUser) ->
        # if user not exists
        if !thisUser
          console.log 'user not exists. create one ...'
          # create a new user
          db.User.create(jUser).then (createdUser) ->
            if createdUser
              #doCreateOrder(createdUser.id)
              console.log '======================>\n
              new user created. ===>\n',createdUser.get()
              done(null,createdUser.id)
        # user exists.
        else
          console.log 'find a exist user. id===>',thisUser.id
          done(null,createdUser.id)

    # step 3 : insert a new order
    doCreateOrder = (done, userid) ->
      # build a order
      theDate = new Date
      newOrder = {
        quantity: quantity
        UserId : userid
        # odrer id
        #########################
        # orderId: theDate.getTime()
        #########################
      }

      # insert the order
      db.Order.create(newOrder).then (createdOrder) ->
        if createdOrder
          console.log '======================>\n
          new order includes ==>\n',createdOrder.get()
          result.order = createdOrder
          result.success = true
          done(null)
        else
          result.order = null
          result.success = false
          done(msg: '建立訂單失敗')

    # do works async just in case.
    async.series [
      doFindProduct
      doFindOrCreateUser
      doCreateOrder
    ], (err, results) ->
      console.log 'error', err
      return res.ok {
        order: result.order
        success: result.success
      }

  # order status section
  status:  (req, res) ->
    console.log req.body.orderId
    console.log req.body.email

    db.User.findOne(
      where:
        email:req.body.email
    )
    .then (userData) ->
      return res.ok {msg: '沒有此User' } if userData is null

      db.Order.findOne(
        where:
          orderId:req.body.orderId
          UserId:userData.id
      )
      .then (orderProduct) ->
        if orderProduct?
          order = {
              id: orderProduct.orderId
              quantity: orderProduct.quantity
              user: {
                username: userData.username
                email: userData.email
                mobile: userData.mobile
                address: userData.address
              }
            }
          res.ok { order : order }
        else
          #沒有此訂單編號時在這處理
          res.ok { msg: '沒有此訂單' }


module.exports = OrderController
